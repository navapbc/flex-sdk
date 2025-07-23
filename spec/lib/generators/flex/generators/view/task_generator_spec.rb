require 'rails_helper'
require 'generators/flex/view/task/task_generator'
require 'fileutils'
require 'tmpdir'

RSpec.describe Flex::Generators::View::TaskGenerator, type: :generator do
  let(:destination_root) { Dir.mktmpdir }
  let(:generator) { described_class.new([ task_name ] + view_types, options.merge(quiet: true), destination_root: destination_root) }
  let(:task_name) { 'ReviewApplication' }
  let(:view_types) { [] }
  let(:options) { {} }

  before do
    FileUtils.mkdir_p("#{destination_root}/app/views")
  end

  after do
    FileUtils.rm_rf(destination_root)
  end

  describe "view directory creation" do
    let(:view_types) { [ "index" ] }

    before do
      generator.invoke_all
    end

    it "creates the view directory" do
      expect(Dir.exist?("#{destination_root}/app/views/review_application")).to be true
    end
  end

  describe "view type generation" do
    context "when no view types are specified" do
      let(:view_types) { [] }

      it "raises an error" do
        expect { generator.invoke_all }.to raise_error("You must provide at least one view type (index, show)")
      end
    end

    context "when only index view type is specified" do
      let(:view_types) { [ "index" ] }

      before do
        generator.invoke_all
      end

      it "generates only index view" do
        index_file = "#{destination_root}/app/views/review_application/index.html.erb"
        show_file = "#{destination_root}/app/views/review_application/show.html.erb"
        details_dir = "#{destination_root}/app/views/review_application/details"
        partial_file = "#{destination_root}/app/views/review_application/details/_review_application_type.html.erb"

        expect(File.exist?(index_file)).to be true
        expect(File.exist?(show_file)).to be false
        expect(Dir.exist?(details_dir)).to be false
        expect(File.exist?(partial_file)).to be false

        content = File.read(index_file)
        expect(content).to include("render template: 'flex/tasks/index'")
        expect(content).to include("@review_applications")
        expect(content).to include("Replace @review_applications with your array of tasks")
      end
    end

    context "when only show view type is specified" do
      let(:view_types) { [ "show" ] }

      before do
        generator.invoke_all
      end

      it "generates only show view and details" do
        index_file = "#{destination_root}/app/views/review_application/index.html.erb"
        show_file = "#{destination_root}/app/views/review_application/show.html.erb"
        details_dir = "#{destination_root}/app/views/review_application/details"
        partial_file = "#{destination_root}/app/views/review_application/details/_review_application_type.html.erb"

        expect(File.exist?(index_file)).to be false
        expect(File.exist?(show_file)).to be true
        expect(Dir.exist?(details_dir)).to be true
        expect(File.exist?(partial_file)).to be true

        show_content = File.read(show_file)
        expect(show_content).to include("render template: 'flex/tasks/show'")
        expect(show_content).to include("@review_application")

        partial_content = File.read(partial_file)
        expect(partial_content).to include("review_application")
      end
    end

    context "when both index and show view types are specified" do
      let(:view_types) { [ "index", "show" ] }

      before do
        generator.invoke_all
      end

      it "generates both index and show views" do
        index_file = "#{destination_root}/app/views/review_application/index.html.erb"
        show_file = "#{destination_root}/app/views/review_application/show.html.erb"
        details_dir = "#{destination_root}/app/views/review_application/details"
        partial_file = "#{destination_root}/app/views/review_application/details/_review_application_type.html.erb"

        expect(File.exist?(index_file)).to be true
        expect(File.exist?(show_file)).to be true
        expect(Dir.exist?(details_dir)).to be true
        expect(File.exist?(partial_file)).to be true

        index_content = File.read(index_file)
        expect(index_content).to include("render template: 'flex/tasks/index'")
        expect(index_content).to include("@review_applications")

        show_content = File.read(show_file)
        expect(show_content).to include("render template: 'flex/tasks/show'")
        expect(show_content).to include("@review_application")

        partial_content = File.read(partial_file)
        expect(partial_content).to include("review_application")
      end
    end
  end

  describe "name formatting" do
    [
      [ 'ProcessPayment', 'process_payment' ],
      [ 'ReviewTask', 'review_task' ],
      [ 'VALIDATE_APPLICATION', 'validate_application' ]
    ].each do |input, expected_underscore|
      context "when name is '#{input}'" do
        let(:task_name) { input }
        let(:view_types) { [ "index" ] }

        before do
          generator.invoke_all
        end

        it "creates directory with underscored name '#{expected_underscore}'" do
          expect(Dir.exist?("#{destination_root}/app/views/#{expected_underscore}")).to be true
          expect(File.exist?("#{destination_root}/app/views/#{expected_underscore}/index.html.erb")).to be true
        end
      end
    end
  end

  describe "file collision detection" do
    let(:view_types) { [ "index", "show" ] }

    before do
      FileUtils.mkdir_p("#{destination_root}/app/views/review_application")
      File.write("#{destination_root}/app/views/review_application/index.html.erb", "existing content")
    end

    it "raises error when files already exist" do
      expect { generator.invoke_all }.to raise_error(/File already exists at app\/views\/review_application\/index\.html\.erb/)
    end
  end

  describe "template content" do
    let(:view_types) { [ "index", "show" ] }

    before do
      generator.invoke_all
    end

    it "generates index template with correct variable names" do
      index_file = "#{destination_root}/app/views/review_application/index.html.erb"
      content = File.read(index_file)

      expect(content).to include("render template: 'flex/tasks/index'")
      expect(content).to include("@review_applications")
      expect(content).to include("@unassigned_review_applications")
      expect(content).to include("Replace @review_applications with your array of tasks")
    end

    it "generates show template with correct variable names" do
      show_file = "#{destination_root}/app/views/review_application/show.html.erb"
      content = File.read(show_file)

      expect(content).to include("render template: 'flex/tasks/show'")
      expect(content).to include("@review_application")
      expect(content).to include("Replace @review_application with your Flex task to use")
    end

    it "generates task type partial with instructions" do
      partial_file = "#{destination_root}/app/views/review_application/details/_review_application_type.html.erb"
      content = File.read(partial_file)

      expect(content).to include("review_application")
      expect(content).to include("Task type partial")
      expect(content).to include("Available locals:")
    end
  end

  describe "edge cases" do
    context "with single word name" do
      let(:task_name) { "Review" }
      let(:view_types) { [ "show" ] }

      before do
        generator.invoke_all
      end

      it "creates correct partial file name" do
        partial_file = "#{destination_root}/app/views/review/details/_review_type.html.erb"
        expect(File.exist?(partial_file)).to be true
      end
    end

    context "with compound name" do
      let(:task_name) { "ProcessPaymentRequest" }
      let(:view_types) { [ "show" ] }

      before do
        generator.invoke_all
      end

      it "creates correct partial file name" do
        partial_file = "#{destination_root}/app/views/process_payment_request/details/_process_payment_request_type.html.erb"
        expect(File.exist?(partial_file)).to be true
      end
    end
  end
end
