require "rails_helper"
require "generators/flex/business_process/business_process_generator"

RSpec.describe Flex::Generators::BusinessProcessGenerator, type: :generator do
  let(:destination_root) { Dir.mktmpdir }
  let(:case_option) { nil }
  let(:app_form_option) { nil }
  let(:options) { { case: case_option, "application-form": app_form_option } }
  let(:generator) { described_class.new([ 'TestProcess' ], options, destination_root: destination_root) }

  before do
    allow(generator).to receive(:generate).and_call_original
    allow(generator).to receive(:yes?).and_return(false)
  end

  after do
    FileUtils.remove_entry(destination_root)
  end

  describe "#create_business_process_file" do
    before do
      FileUtils.mkdir_p("#{destination_root}/config")
      File.write("#{destination_root}/config/application.rb", <<~RUBY)
        require_relative "boot"

        require "rails/all"

        Bundler.require(*Rails.groups)

        module Dummy
          class Application < Rails::Application
            config.load_defaults Rails::VERSION::STRING.to_f
          end
        end
      RUBY
    end

    it "creates a business process file" do
      generator.invoke_all
      expect(File.exist?("#{destination_root}/app/business_processes/test_process_business_process.rb")).to be true
    end

    it "raises an error if the file already exists" do
      FileUtils.mkdir_p("#{destination_root}/app/business_processes")
      File.write("#{destination_root}/app/business_processes/test_process_business_process.rb", "existing content")

      expect { generator.invoke_all }.to raise_error("Business process file already exists at app/business_processes/test_process_business_process.rb")
    end

    it "creates the business process file with the correct content" do
      generator.invoke_all
      content = File.read("#{destination_root}/app/business_processes/test_process_business_process.rb")
      expect(content).to include("class TestProcessBusinessProcess")
      expect(content).to include("case_class TestProcessCase")
      expect(content).to include("application_form_class TestProcessApplicationForm")
    end

    describe "with custom case option" do
      let(:case_option) { "CustomCase" }

      it "uses the custom case class" do
        generator.invoke_all
        content = File.read("#{destination_root}/app/business_processes/test_process_business_process.rb")
        expect(content).to include("case_class CustomCase")
      end
    end

    describe "with custom application form option" do
      let(:app_form_option) { "CustomApplicationForm" }

      it "uses the custom application form class" do
        generator.invoke_all
        content = File.read("#{destination_root}/app/business_processes/test_process_business_process.rb")
        expect(content).to include("application_form_class CustomApplicationForm")
      end
    end
  end

  describe "#update_application_config" do
    before do
      FileUtils.mkdir_p("#{destination_root}/config")
    end

    it "adds config.after_initialize block when none exists" do
      File.write("#{destination_root}/config/application.rb", <<~RUBY)
        require_relative "boot"

        require "rails/all"

        Bundler.require(*Rails.groups)

        module Dummy
          class Application < Rails::Application
            config.load_defaults Rails::VERSION::STRING.to_f
          end
        end
      RUBY

      generator.invoke_all

      content = File.read("#{destination_root}/config/application.rb")
      expect(content).to include("config.after_initialize do")
      expect(content).to include("TestProcessBusinessProcess.start_listening_for_events")
    end

    it "appends to existing after_initialize block" do
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

      generator.invoke_all

      content = File.read("#{destination_root}/config/application.rb")

      expected = <<~RUBY
        require_relative "boot"

        require "rails/all"

        Bundler.require(*Rails.groups)

        module Dummy
          class Application < Rails::Application
            config.load_defaults Rails::VERSION::STRING.to_f

            config.after_initialize do
              # existing code
              TestProcessBusinessProcess.start_listening_for_events
            end
          end
        end
      RUBY

      # rstrip to remove trailing newline
      expect(content.rstrip).to eq(expected.rstrip)
    end
  end

  describe "when start_listening_for_events already exists" do
    before do
      FileUtils.mkdir_p("#{destination_root}/config")
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

      generator_with_duplicate = described_class.new([ 'Test' ], { quiet: true }, destination_root: destination_root)
      allow(generator_with_duplicate).to receive(:generate).and_call_original
      allow(generator_with_duplicate).to receive(:yes?).and_return(false)
      generator_with_duplicate.invoke_all
    end

    it "does not duplicate the call" do
      content = File.read("#{destination_root}/config/application.rb")
      occurrences = content.scan(/TestBusinessProcess\.start_listening_for_events/).length
      expect(occurrences).to eq(1)
    end
  end

  describe "case generation" do
    before do
      FileUtils.mkdir_p("#{destination_root}/config")
      File.write("#{destination_root}/config/application.rb", <<~RUBY)
        require_relative "boot"

        require "rails/all"

        Bundler.require(*Rails.groups)

        module Dummy
          class Application < Rails::Application
            config.load_defaults Rails::VERSION::STRING.to_f
          end
        end
      RUBY
    end

    describe "when case exists" do
      before do
        stub_const("TestProcessCase", Class.new)
        stub_const("TestProcessApplicationForm", Class.new)
        allow(generator).to receive(:generate)
        allow(generator).to receive(:yes?)
        generator.invoke_all
      end

      it "does not prompt user" do
        expect(generator).not_to have_received(:yes?)
      end

      it "does not generate case" do
        expect(generator).not_to have_received(:generate).with("flex:case", anything)
      end
    end

    describe "when case does not exist and user declines" do
      before do
        stub_const("TestProcessApplicationForm", Class.new)
        allow(generator).to receive(:generate)
        allow(generator).to receive(:yes?).and_return(false)
        generator.invoke_all
      end

      it "prompts user once for case" do
        expect(generator).to have_received(:yes?).with("Case TestProcessCase does not exist. Generate it? (y/n)").exactly(1).times
      end

      it "does not generate case" do
        expect(generator).not_to have_received(:generate).with("flex:case", anything)
      end
    end

    describe "when case does not exist and user agrees" do
      before do
        stub_const("TestProcessApplicationForm", Class.new)
        allow(generator).to receive(:generate)
        allow(generator).to receive(:yes?).and_return(true)
        generator.invoke_all
      end

      it "prompts user once for case" do
        expect(generator).to have_received(:yes?).with("Case TestProcessCase does not exist. Generate it? (y/n)").exactly(1).times
      end

      it "generates case" do
        expect(generator).to have_received(:generate).with("flex:case", "TestProcess").exactly(1).times
      end
    end

    describe "with skip-case option" do
      let(:options) { { case: case_option, "application-form": app_form_option, "skip-case": true } }

      before do
        stub_const("TestProcessApplicationForm", Class.new)
        allow(generator).to receive(:generate)
        allow(generator).to receive(:yes?)
        generator.invoke_all
      end

      it "does not prompt user for case" do
        expect(generator).not_to have_received(:yes?).with("Case TestProcessCase does not exist. Generate it? (y/n)")
      end

      it "does not generate case" do
        expect(generator).not_to have_received(:generate).with("flex:case", anything)
      end
    end

    describe "with force-case option" do
      let(:options) { { case: case_option, "application-form": app_form_option, "force-case": true } }

      before do
        stub_const("TestProcessApplicationForm", Class.new)
        allow(generator).to receive(:generate)
        allow(generator).to receive(:yes?)
        generator.invoke_all
      end

      it "does not prompt user for case" do
        expect(generator).not_to have_received(:yes?).with("Case TestProcessCase does not exist. Generate it? (y/n)")
      end

      it "generates case" do
        expect(generator).to have_received(:generate).with("flex:case", "TestProcess").exactly(1).times
      end
    end

    describe "when case name does not end with Case" do
      let(:options) { { case: "CustomForm", "application-form": app_form_option, "force-case": true } }

      before do
        allow(generator).to receive(:generate)
        allow(generator).to receive(:yes?)
        generator.invoke_all
      end

      it "uses the full name as base name" do
        expect(generator).to have_received(:generate).with("flex:case", "CustomForm").exactly(1).times
      end
    end

    describe "when case is namespaced" do
      let(:options) { { case: "MyModule::TestProcessCase", "application-form": app_form_option, "force-case": true } }

      before do
        allow(generator).to receive(:generate)
        allow(generator).to receive(:yes?)
        generator.invoke_all
      end

      it "correctly extracts base name from namespaced class" do
        expect(generator).to have_received(:generate).with("flex:case", "MyModule::TestProcess").exactly(1).times
      end
    end
  end

  describe "application form generation" do
    before do
      FileUtils.mkdir_p("#{destination_root}/config")
      File.write("#{destination_root}/config/application.rb", <<~RUBY)
        require_relative "boot"

        require "rails/all"

        Bundler.require(*Rails.groups)

        module Dummy
          class Application < Rails::Application
            config.load_defaults Rails::VERSION::STRING.to_f
          end
        end
      RUBY
    end

    context "when application form exists" do
      before do
        stub_const("TestProcessCase", Class.new)
        stub_const("TestProcessApplicationForm", Class.new)
        allow(generator).to receive(:generate)
        allow(generator).to receive(:yes?)
        generator.invoke_all
      end

      it "does not prompt user" do
        expect(generator).not_to have_received(:yes?)
      end

      it "does not generate application form" do
        expect(generator).not_to have_received(:generate).with("flex:application_form", anything)
      end
    end

    context "when application form does not exist and user declines" do
      before do
        stub_const("TestProcessCase", Class.new)
        allow(generator).to receive(:generate)
        allow(generator).to receive(:yes?).and_return(false)
        generator.invoke_all
      end

      it "prompts user once for application form" do
        expect(generator).to have_received(:yes?).with("Application form TestProcessApplicationForm does not exist. Generate it? (y/n)").exactly(1).times
      end

      it "does not generate application form" do
        expect(generator).not_to have_received(:generate).with("flex:application_form", anything)
      end
    end

    context "when application form does not exist and user agrees" do
      before do
        stub_const("TestProcessCase", Class.new)
        allow(generator).to receive(:generate)
        allow(generator).to receive(:yes?).and_return(true)
        generator.invoke_all
      end

      it "prompts user once for application form" do
        expect(generator).to have_received(:yes?).with("Application form TestProcessApplicationForm does not exist. Generate it? (y/n)").exactly(1).times
      end

      it "generates application form" do
        expect(generator).to have_received(:generate).with("flex:application_form", "TestProcess").exactly(1).times
      end
    end

    context "when TestApplicationForm does not exist and skip-application-form option is provided" do
      let(:options) { { case: case_option, "application-form": app_form_option, "skip-application-form": true } }

      before do
        stub_const("TestProcessCase", Class.new)
        allow(generator).to receive(:generate)
        allow(generator).to receive(:yes?)
        generator.invoke_all
      end

      it "does not prompt user for application form" do
        expect(generator).not_to have_received(:yes?).with("Application form TestProcessApplicationForm does not exist. Generate it? (y/n)")
      end

      it "does not generate application form" do
        expect(generator).not_to have_received(:generate).with("flex:application_form", anything)
      end
    end

    describe "with force-application-form option" do
      let(:options) { { case: case_option, "application-form": app_form_option, "force-application-form": true } }

      before do
        stub_const("TestProcessCase", Class.new)
        allow(generator).to receive(:generate)
        allow(generator).to receive(:yes?)
        generator.invoke_all
      end

      it "does not prompt user for application form" do
        expect(generator).not_to have_received(:yes?).with("Application form TestProcessApplicationForm does not exist. Generate it? (y/n)")
      end

      it "generates application form" do
        expect(generator).to have_received(:generate).with("flex:application_form", "TestProcess").exactly(1).times
      end
    end

    describe "when application form name does not end with ApplicationForm" do
      let(:options) { { case: case_option, "application-form": "CustomForm", "force-application-form": true } }

      before do
        allow(generator).to receive(:generate)
        allow(generator).to receive(:yes?)
        generator.invoke_all
      end

      it "uses the full name as base name" do
        expect(generator).to have_received(:generate).with("flex:application_form", "CustomForm").exactly(1).times
      end
    end

    describe "when application form is namespaced" do
      let(:options) { { case: case_option, "application-form": "MyModule::TestProcessApplicationForm", "force-application-form": true } }

      before do
        allow(generator).to receive(:generate)
        allow(generator).to receive(:yes?)
        generator.invoke_all
      end

      it "correctly extracts base name from namespaced class" do
        expect(generator).to have_received(:generate).with("flex:application_form", "MyModule::TestProcess").exactly(1).times
      end
    end
  end
end
