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
    before do
      generator.invoke_all
    end

    it "creates the view directory" do
      expect(Dir.exist?("#{destination_root}/app/views/passport_application")).to be true
    end
  end

  describe "view type generation" do
    [
      [ [], "generates no files when no view types specified" ],
      [ [ "index" ], "generates only index view when index specified" ],
      [ [ "show" ], "generates only show view when show specified" ],
      [ [ "index", "show" ], "generates both index and show views when both specified" ]
    ].each do |types, description|
      context "with view_types #{types}" do
        let(:view_types) { types }

        before do
          generator.invoke_all
        end

        it description do
          index_file = "#{destination_root}/app/views/passport_application/index.html.erb"
          show_file = "#{destination_root}/app/views/passport_application/show.html.erb"

          if types.include?("index")
            expect(File.exist?(index_file)).to be true
            content = File.read(index_file)
            expect(content).to include("passport_applications")
            expect(content).to include("passport_application")
            expect(content).to include("model_class")
          else
            expect(File.exist?(index_file)).to be false
          end

          if types.include?("show")
            expect(File.exist?(show_file)).to be true

            show_content = File.read(show_file)
            expect(show_content).to include("passport_application")
            expect(show_content).to include("model_class")
            expect(show_content).to include("case_summary")
            expect(show_content).to include("case_details")
          else
            expect(File.exist?(show_file)).to be false
          end
        end
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

      expect(content).to include("passport_applications")
      expect(content).to include("passport_application")
      expect(content).to include("model_class")
      expect(content).to include("polymorphic_path")
    end

    it "generates show template with correct variable names" do
      show_file = "#{destination_root}/app/views/passport_application/show.html.erb"
      content = File.read(show_file)

      expect(content).to include("passport_application")
      expect(content).to include("model_class")
      expect(content).to include("case_summary")
      expect(content).to include("case_details")
      expect(content).to include("status_tag")
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
        expect(content).to include("documents")
        expect(content).to include("document")
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
        expect(content).to include("liquor_license_application")
      end
    end
  end
end
