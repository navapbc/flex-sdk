require 'rails_helper'
require 'generators/business_process/business_process_generator'
require 'fileutils'
require 'tmpdir'

RSpec.describe BusinessProcessGenerator do
  let(:destination_root) { Dir.mktmpdir }
  let(:generator) { described_class.new([ 'TestProcess' ], { case: case_option, application_form: app_form_option }, destination_root: destination_root) }
  let(:case_option) { nil }
  let(:app_form_option) { nil }

  before do
    FileUtils.mkdir_p("#{destination_root}/app/business_processes")
    FileUtils.mkdir_p("#{destination_root}/config")

    File.write("#{destination_root}/config/application.rb", <<~RUBY)
      require_relative "boot"

      require "rails/all"

      Bundler.require(*Rails.groups)

      module Dummy
        class Application < Rails::Application
          config.load_defaults Rails::VERSION::STRING.to_f

          config.action_controller.include_all_helpers = false

          config.autoload_lib(ignore: %w[assets tasks])
        end
      end
    RUBY
  end

  after do
    FileUtils.rm_rf(destination_root)
  end

  describe "with basic name only" do
    before do
      generator.invoke_all
    end

    it "creates business process file with correct naming" do
      business_process_file = "#{destination_root}/app/business_processes/test_process_business_process.rb"
      expect(File.exist?(business_process_file)).to be true

      content = File.read(business_process_file)
      expect(content).to include("TestProcessBusinessProcess = Flex::BusinessProcess.define(:test_process, TestProcessCase)")
      expect(content).to include("bp.transition('submit_application', 'TestProcessApplicationFormSubmitted', 'example_1')")
    end

    it "updates application.rb with start_listening_for_events call" do
      application_file = "#{destination_root}/config/application.rb"
      content = File.read(application_file)
      expect(content).to include("config.after_initialize do")
      expect(content).to include("TestProcessBusinessProcess.start_listening_for_events")
    end
  end

  describe "with custom case option" do
    let(:case_option) { 'Moon' }

    before do
      generator.invoke_all
    end

    it "uses custom case name" do
      business_process_file = "#{destination_root}/app/business_processes/test_process_business_process.rb"
      content = File.read(business_process_file)
      expect(content).to include("TestProcessBusinessProcess = Flex::BusinessProcess.define(:test_process, Moon)")
      expect(content).to include("bp.transition('submit_application', 'TestProcessApplicationFormSubmitted', 'example_1')")
    end
  end

  describe "with custom case and application_form options" do
    let(:case_option) { 'Doggy' }
    let(:app_form_option) { 'Rabbit' }

    before do
      generator.invoke_all
    end

    it "uses custom case and application form names" do
      business_process_file = "#{destination_root}/app/business_processes/test_process_business_process.rb"
      content = File.read(business_process_file)
      expect(content).to include("TestProcessBusinessProcess = Flex::BusinessProcess.define(:test_process, Doggy)")
      expect(content).to include("bp.transition('submit_application', 'RabbitSubmitted', 'example_1')")
    end
  end

  describe "when business process file already exists" do
    before do
      File.write("#{destination_root}/app/business_processes/test_process_business_process.rb", "# existing file")
    end

    it "raises an error" do
      expect {
        generator.invoke_all
      }.to raise_error(/Business process file already exists/)
    end
  end

  describe "when config.after_initialize already exists" do
    let(:generator_with_existing_config) { described_class.new([ 'Test' ], {}, destination_root: destination_root) }

    before do
      File.write("#{destination_root}/config/application.rb", <<~RUBY)
        require_relative "boot"

        require "rails/all"

        Bundler.require(*Rails.groups)

        module Dummy
          class Application < Rails::Application
            config.load_defaults Rails::VERSION::STRING.to_f

            config.after_initialize do
              # existing code
            end
          end
        end
      RUBY

      generator_with_existing_config.invoke_all
    end

    it "appends to existing after_initialize block" do
      content = File.read("#{destination_root}/config/application.rb")
      expect(content).to include("config.after_initialize do")
      expect(content).to include("# existing code")
      expect(content).to include("TestBusinessProcess.start_listening_for_events")
    end
  end

  describe "when start_listening_for_events already exists" do
    let(:generator_with_duplicate) { described_class.new([ 'Test' ], {}, destination_root: destination_root) }

    before do
      File.write("#{destination_root}/config/application.rb", <<~RUBY)
        require_relative "boot"

        require "rails/all"

        Bundler.require(*Rails.groups)

        module Dummy
          class Application < Rails::Application
            config.load_defaults Rails::VERSION::STRING.to_f

            config.after_initialize do
              TestBusinessProcess.start_listening_for_events
            end
          end
        end
      RUBY

      generator_with_duplicate.invoke_all
    end

    it "does not duplicate the call" do
      content = File.read("#{destination_root}/config/application.rb")
      occurrences = content.scan(/TestBusinessProcess\.start_listening_for_events/).length
      expect(occurrences).to eq(1)
    end
  end
end
