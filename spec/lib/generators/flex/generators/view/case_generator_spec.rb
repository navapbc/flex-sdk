require 'rails_helper'
require 'generators/flex/view/case/case_generator'
require 'fileutils'
require 'tmpdir'

RSpec.describe Flex::Generators::View::CaseGenerator, type: :generator do
  let(:destination_root) { Dir.mktmpdir }
  let(:generator) { described_class.new([ case_name ] + view_types, options.merge(quiet: true), destination_root: destination_root) }
  let(:case_name) { 'PassportApplication' }
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
      expect(Dir.exist?("#{destination_root}/app/views/passport_application")).to be true
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
        index_file = "#{destination_root}/app/views/passport_application/index.html.erb"
        show_file = "#{destination_root}/app/views/passport_application/show.html.erb"

        expect(File.exist?(index_file)).to be true
        expect(File.exist?(show_file)).to be false

        content = File.read(index_file)
        expect(content).to include("render template: 'flex/cases/index'")
        expect(content).to include("PassportApplication")
        expect(content).to include("Replace `PassportApplication` with the name of the model class")
      end
    end

    context "when only show view type is specified" do
      let(:view_types) { [ "show" ] }

      before do
        generator.invoke_all
      end

      it "generates only show view" do
        index_file = "#{destination_root}/app/views/passport_application/index.html.erb"
        show_file = "#{destination_root}/app/views/passport_application/show.html.erb"

        expect(File.exist?(index_file)).to be false
        expect(File.exist?(show_file)).to be true

        show_content = File.read(show_file)
        expect(show_content).to include("render template: 'flex/cases/show'")
        expect(show_content).to include("PassportApplication")
        expect(show_content).to include("content_for :case_summary")
        expect(show_content).to include("content_for :case_details")
      end
    end

    context "when both index and show view types are specified" do
      let(:view_types) { [ "index", "show" ] }

      before do
        generator.invoke_all
      end

      it "generates both index and show views" do
        index_file = "#{destination_root}/app/views/passport_application/index.html.erb"
        show_file = "#{destination_root}/app/views/passport_application/show.html.erb"

        expect(File.exist?(index_file)).to be true
        expect(File.exist?(show_file)).to be true

        index_content = File.read(index_file)
        expect(index_content).to include("render template: 'flex/cases/index'")
        expect(index_content).to include("PassportApplication")

        show_content = File.read(show_file)
        expect(show_content).to include("render template: 'flex/cases/show'")
        expect(show_content).to include("PassportApplication")
        expect(show_content).to include("content_for :case_summary")
        expect(show_content).to include("content_for :case_details")
      end
    end
  end

  describe "name formatting" do
    [
      [ 'BenefitsCase', 'benefits_case' ],
      [ 'MedicaidApplication', 'medicaid_application' ],
      [ 'PASSPORT_RENEWAL', 'passport_renewal' ]
    ].each do |input, expected_underscore|
      context "when name is '#{input}'" do
        let(:case_name) { input }
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
      FileUtils.mkdir_p("#{destination_root}/app/views/passport_application")
      File.write("#{destination_root}/app/views/passport_application/show.html.erb", "existing content")
    end

    it "raises error when files already exist" do
      expect { generator.invoke_all }.to raise_error(/File already exists at app\/views\/passport_application\/show\.html\.erb/)
    end
  end

  describe "template content" do
    let(:view_types) { [ "index", "show" ] }

    before do
      generator.invoke_all
    end

    it "generates index template with correct variable names" do
      index_file = "#{destination_root}/app/views/passport_application/index.html.erb"
      content = File.read(index_file)

      expect(content).to include("render template: 'flex/cases/index'")
      expect(content).to include("PassportApplication")
      expect(content).to include("Replace `PassportApplication` with the name of the model class")
    end

    it "generates show template with correct variable names" do
      show_file = "#{destination_root}/app/views/passport_application/show.html.erb"
      content = File.read(show_file)

      expect(content).to include("render template: 'flex/cases/show'")
      expect(content).to include("PassportApplication")
      expect(content).to include("content_for :case_summary")
      expect(content).to include("content_for :case_details")
    end
  end

  describe "edge cases" do
    context "with single word name" do
      let(:case_name) { "Document" }
      let(:view_types) { [ "index" ] }

      before do
        generator.invoke_all
      end

      it "creates correct directory and files" do
        expect(Dir.exist?("#{destination_root}/app/views/document")).to be true
        expect(File.exist?("#{destination_root}/app/views/document/index.html.erb")).to be true

        content = File.read("#{destination_root}/app/views/document/index.html.erb")
        expect(content).to include("render template: 'flex/cases/index'")
        expect(content).to include("Document")
      end
    end

    context "with compound name" do
      let(:case_name) { "LiquorLicenseApplication" }
      let(:view_types) { [ "show" ] }

      before do
        generator.invoke_all
      end

      it "creates correct directory and files" do
        expect(Dir.exist?("#{destination_root}/app/views/liquor_license_application")).to be true
        expect(File.exist?("#{destination_root}/app/views/liquor_license_application/show.html.erb")).to be true

        content = File.read("#{destination_root}/app/views/liquor_license_application/show.html.erb")
        expect(content).to include("render template: 'flex/cases/show'")
        expect(content).to include("LiquorLicenseApplication")
      end
    end
  end
end
