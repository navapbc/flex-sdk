require 'rails_helper'
require 'generators/flex/case/case_generator'
require 'fileutils'
require 'tmpdir'

RSpec.describe Flex::Generators::CaseGenerator, type: :generator do
  let(:destination_root) { Dir.mktmpdir }
  let(:generator) { described_class.new([ name ] + attributes, options.merge(quiet: true), destination_root: destination_root) }
  let(:name) { 'TestCase' }
  let(:attributes) { [] }
  let(:options) { {} }

  before do
    FileUtils.mkdir_p("#{destination_root}/app/models")
    FileUtils.mkdir_p("#{destination_root}/spec/models")
    allow(generator).to receive(:generate)
  end

  after do
    FileUtils.rm_rf(destination_root)
  end

  describe "name transformation" do
    context "with basic name" do
      let(:name) { "Passport" }

      before do
        allow(generator).to receive(:yes?).and_return(false)
        generator.invoke_all
      end

      it "transforms 'Passport' to 'PassportCase' with base attributes" do
        expect(generator).to have_received(:generate).with(
          "flex:model",
          "PassportCase",
          "application_form_id:uuid",
          "status:integer",
          "business_process_current_step:string",
          "facts:jsonb",
          "--parent",
          "Flex::Case"
        )
      end
    end

    context "with name already having Case suffix" do
      let(:name) { "PassportCase" }

      before do
        allow(generator).to receive(:yes?).and_return(false)
        generator.invoke_all
      end

      it "keeps 'PassportCase' as 'PassportCase' with base attributes" do
        expect(generator).to have_received(:generate).with(
          "flex:model",
          "PassportCase",
          "application_form_id:uuid",
          "status:integer",
          "business_process_current_step:string",
          "facts:jsonb",
          "--parent",
          "Flex::Case"
        )
      end
    end

    context "with mixed case name" do
      let(:name) { "BenefitsApplication" }

      before do
        allow(generator).to receive(:yes?).and_return(false)
        generator.invoke_all
      end

      it "transforms 'BenefitsApplication' to 'BenefitsApplicationCase' with base attributes" do
        expect(generator).to have_received(:generate).with(
          "flex:model",
          "BenefitsApplicationCase",
          "application_form_id:uuid",
          "status:integer",
          "business_process_current_step:string",
          "facts:jsonb",
          "--parent",
          "Flex::Case"
        )
      end
    end

    context "with single word" do
      let(:name) { "Review" }

      before do
        allow(generator).to receive(:yes?).and_return(false)
        generator.invoke_all
      end

      it "transforms 'Review' to 'ReviewCase' with base attributes" do
        expect(generator).to have_received(:generate).with(
          "flex:model",
          "ReviewCase",
          "application_form_id:uuid",
          "status:integer",
          "business_process_current_step:string",
          "facts:jsonb",
          "--parent",
          "Flex::Case"
        )
      end
    end

    context "with lowercase name" do
      let(:name) { "document" }

      before do
        allow(generator).to receive(:yes?).and_return(false)
        generator.invoke_all
      end

      it "transforms 'document' to 'DocumentCase' with base attributes" do
        expect(generator).to have_received(:generate).with(
          "flex:model",
          "DocumentCase",
          "application_form_id:uuid",
          "status:integer",
          "business_process_current_step:string",
          "facts:jsonb",
          "--parent",
          "Flex::Case"
        )
      end
    end
  end

  describe "attribute handling" do
    context "with no attributes" do
      before do
        allow(generator).to receive(:yes?).and_return(false)
        generator.invoke_all
      end

      it "includes base attributes from Flex::Case" do
        expect(generator).to have_received(:generate).with(
          "flex:model",
          "TestCase",
          "application_form_id:uuid",
          "status:integer",
          "business_process_current_step:string",
          "facts:jsonb",
          "--parent",
          "Flex::Case"
        )
      end
    end

    context "with standard attributes" do
      let(:attributes) { [ "name:string", "email:string" ] }

      before do
        allow(generator).to receive(:yes?).and_return(false)
        generator.invoke_all
      end

      it "merges base attributes with user-provided attributes" do
        expect(generator).to have_received(:generate).with(
          "flex:model",
          "TestCase",
          "application_form_id:uuid",
          "status:integer",
          "business_process_current_step:string",
          "facts:jsonb",
          "name:string",
          "email:string",
          "--parent",
          "Flex::Case"
        )
      end
    end

    context "with flex attributes" do
      let(:attributes) { [ "applicant_name:name", "home_address:address" ] }

      before do
        allow(generator).to receive(:yes?).and_return(false)
        generator.invoke_all
      end

      it "merges base attributes with flex attributes" do
        expect(generator).to have_received(:generate).with(
          "flex:model",
          "TestCase",
          "application_form_id:uuid",
          "status:integer",
          "business_process_current_step:string",
          "facts:jsonb",
          "applicant_name:name",
          "home_address:address",
          "--parent",
          "Flex::Case"
        )
      end
    end

    context "with mixed attributes" do
      let(:attributes) { [ "priority:integer", "applicant_name:name" ] }

      before do
        allow(generator).to receive(:yes?).and_return(false)
        generator.invoke_all
      end

      it "merges base attributes with user-provided attributes" do
        expect(generator).to have_received(:generate).with(
          "flex:model",
          "TestCase",
          "application_form_id:uuid",
          "status:integer",
          "business_process_current_step:string",
          "facts:jsonb",
          "priority:integer",
          "applicant_name:name",
          "--parent",
          "Flex::Case"
        )
      end
    end

    context "with conflicting base attributes" do
      let(:attributes) { [ "status:string", "custom_field:text" ] }

      before do
        allow(generator).to receive(:yes?).and_return(false)
        generator.invoke_all
      end

      it "keeps unique attributes when user redefines a base attribute" do
        expect(generator).to have_received(:generate).with(
          "flex:model",
          "TestCase",
          "application_form_id:uuid",
          "status:integer",
          "business_process_current_step:string",
          "facts:jsonb",
          "status:string",
          "custom_field:text",
          "--parent",
          "Flex::Case"
        )
      end
    end
  end

  describe "STI support" do
    context "with --sti flag" do
      let(:options) { { sti: true } }

      before do
        allow(generator).to receive(:yes?).and_return(false)
        generator.invoke_all
      end

      it "adds type:string attribute along with base attributes" do
        expect(generator).to have_received(:generate).with(
          "flex:model",
          "TestCase",
          "application_form_id:uuid",
          "status:integer",
          "business_process_current_step:string",
          "facts:jsonb",
          "type:string",
          "--parent",
          "Flex::Case"
        )
      end
    end

    context "with --sti flag and other attributes" do
      let(:attributes) { [ "name:string" ] }
      let(:options) { { sti: true } }

      before do
        allow(generator).to receive(:yes?).and_return(false)
        generator.invoke_all
      end

      it "adds type:string attribute along with base and user attributes" do
        expect(generator).to have_received(:generate).with(
          "flex:model",
          "TestCase",
          "application_form_id:uuid",
          "status:integer",
          "business_process_current_step:string",
          "facts:jsonb",
          "name:string",
          "type:string",
          "--parent",
          "Flex::Case"
        )
      end
    end

    context "without --sti flag" do
      before do
        allow(generator).to receive(:yes?).and_return(false)
        generator.invoke_all
      end

      it "includes base attributes without type attribute" do
        expect(generator).to have_received(:generate).with(
          "flex:model",
          "TestCase",
          "application_form_id:uuid",
          "status:integer",
          "business_process_current_step:string",
          "facts:jsonb",
          "--parent",
          "Flex::Case"
        )
      end
    end
  end

  describe "business process integration" do
    context "when business process exists" do
      before do
        stub_const("TestBusinessProcess", Class.new)
        allow(generator).to receive(:yes?)
        generator.invoke_all
      end

      it "does not prompt user" do
        expect(generator).not_to have_received(:yes?)
      end

      it "does not generate business process" do
        expect(generator).not_to have_received(:generate).with("flex:business_process", anything)
      end
    end

    context "when business process does not exist and user declines" do
      before do
        hide_const("TestBusinessProcess")
        allow(generator).to receive(:yes?).and_return(false)
        generator.invoke_all
      end

      it "prompts user once" do
        expect(generator).to have_received(:yes?).with("Business process TestBusinessProcess does not exist. Generate it? (y/n)").once
      end

      it "does not generate business process" do
        expect(generator).not_to have_received(:generate).with("flex:business_process", anything)
      end
    end

    context "when business process does not exist and user agrees" do
      before do
        hide_const("TestBusinessProcess")
        allow(generator).to receive(:yes?).and_return(true)
        generator.invoke_all
      end

      it "prompts user once" do
        expect(generator).to have_received(:yes?).with("Business process TestBusinessProcess does not exist. Generate it? (y/n)").once
      end

      it "generates business process" do
        expect(generator).to have_received(:generate).with("flex:business_process", "Test", "--skip-application-form").once
      end
    end

    context "with custom business process name" do
      let(:options) { { "business-process": "CustomBusinessProcess" } }

      before do
        allow(generator).to receive(:yes?)
        generator.create_case_model
      end

      it "uses custom business process name" do
        expect(generator).not_to have_received(:yes?)
        expect(generator).to have_received(:generate).with("flex:business_process", "CustomBusinessProcess", "--skip-application-form")
      end
    end

    context "with --skip-business-process flag" do
      let(:options) { { "skip-business-process": true } }

      before do
        allow(generator).to receive(:yes?)
        generator.create_case_model
      end

      it "does not prompt user" do
        expect(generator).not_to have_received(:yes?)
      end

      it "does not generate business process" do
        expect(generator).not_to have_received(:generate).with("flex:business_process", anything)
      end
    end
  end

  describe "application form integration" do
    context "when application form exists" do
      before do
        stub_const("TestApplicationForm", Class.new)
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
        hide_const("TestApplicationForm")
        allow(generator).to receive(:yes?).and_return(false)
        generator.invoke_all
      end

      it "prompts user once" do
        expect(generator).to have_received(:yes?).with("Application form TestApplicationForm does not exist. Generate it? (y/n)").once
      end

      it "does not generate application form" do
        expect(generator).not_to have_received(:generate).with("flex:application_form", anything)
      end
    end

    context "when application form does not exist and user agrees" do
      before do
        hide_const("TestApplicationForm")
        allow(generator).to receive(:yes?).and_return(true)
        generator.invoke_all
      end

      it "prompts user once" do
        expect(generator).to have_received(:yes?).with("Application form TestApplicationForm does not exist. Generate it? (y/n)").once
      end

      it "generates application form" do
        expect(generator).to have_received(:generate).with("flex:application_form", "Test").once
      end
    end

    context "with custom application form name" do
      let(:options) { { "application-form": "CustomApplicationForm" } }

      before do
        allow(generator).to receive(:yes?)
        generator.create_case_model
      end

      it "uses custom application form name" do
        expect(generator).not_to have_received(:yes?)
        expect(generator).to have_received(:generate).with("flex:application_form", "CustomApplicationForm")
      end
    end

    context "with --skip-application-form flag" do
      let(:options) { { "skip-application-form": true } }

      before do
        allow(generator).to receive(:yes?)
        generator.create_case_model
      end

      it "does not prompt user" do
        expect(generator).not_to have_received(:yes?)
      end

      it "does not generate application form" do
        expect(generator).not_to have_received(:generate).with("flex:application_form", anything)
      end
    end
  end

  describe "skip flags take precedence over custom names" do
    context "with both skip-business-process flag and custom business process name" do
      let(:options) { { "skip-business-process": true, "business-process": "CustomBP" } }

      before do
        allow(generator).to receive(:yes?)
        generator.create_case_model
      end

      it "respects skip flag over custom name" do
        expect(generator).not_to have_received(:yes?)
        expect(generator).not_to have_received(:generate).with("flex:business_process", anything)
      end
    end

    context "with both skip-application-form flag and custom application form name" do
      let(:options) { { "skip-application-form": true, "application-form": "CustomAF" } }

      before do
        allow(generator).to receive(:yes?)
        generator.create_case_model
      end

      it "respects skip flag over custom name" do
        expect(generator).not_to have_received(:yes?)
        expect(generator).not_to have_received(:generate).with("flex:application_form", anything)
      end
    end
  end

  describe "combined scenarios" do
    context "with both business process and application form missing, user agrees to both" do
      before do
        hide_const("TestBusinessProcess")
        hide_const("TestApplicationForm")
        allow(generator).to receive(:yes?).and_return(true)
        generator.invoke_all
      end

      it "generates both business process and application form" do
        expect(generator).to have_received(:generate).with("flex:business_process", "Test", "--skip-application-form").once
        expect(generator).to have_received(:generate).with("flex:application_form", "Test").once
        expect(generator).to have_received(:generate).with(
          "flex:model",
          "TestCase",
          "application_form_id:uuid",
          "status:integer",
          "business_process_current_step:string",
          "facts:jsonb",
          "--parent",
          "Flex::Case"
        ).once
      end
    end

    context "with custom names for both business process and application form" do
      let(:options) { { "business-process": "CustomBP", "application-form": "CustomAF" } }

      before do
        allow(generator).to receive(:yes?).and_return(true)
        generator.invoke_all
      end

      it "uses custom names for both" do
        expect(generator).to have_received(:generate).with("flex:business_process", "CustomBP", "--skip-application-form").once
        expect(generator).to have_received(:generate).with("flex:application_form", "CustomAF").once
      end
    end

    context "with all options combined" do
      let(:attributes) { [ "name:string", "address:address" ] }
      let(:options) { { sti: true, "business-process": "CustomBP", "application-form": "CustomAF" } }

      before do
        allow(generator).to receive(:yes?).and_return(true)
        generator.invoke_all
      end

      it "handles all options correctly" do
        expect(generator).to have_received(:generate).with("flex:business_process", "CustomBP", "--skip-application-form").once
        expect(generator).to have_received(:generate).with("flex:application_form", "CustomAF").once
        expect(generator).to have_received(:generate).with(
          "flex:model",
          "TestCase",
          "application_form_id:uuid",
          "status:integer",
          "business_process_current_step:string",
          "facts:jsonb",
          "name:string",
          "address:address",
          "type:string",
          "--parent",
          "Flex::Case"
        ).once
      end
    end
  end

  describe "edge cases" do
    context "with name ending in different case" do
      let(:name) { "TestCASE" }

      before do
        allow(generator).to receive(:yes?).and_return(false)
        generator.invoke_all
      end

      it "still appends Case suffix and includes base attributes" do
        expect(generator).to have_received(:generate).with(
          "flex:model",
          "TestCASECase",
          "application_form_id:uuid",
          "status:integer",
          "business_process_current_step:string",
          "facts:jsonb",
          "--parent",
          "Flex::Case"
        )
      end
    end

    context "with name containing Case in middle" do
      let(:name) { "CaseTest" }

      before do
        allow(generator).to receive(:yes?).and_return(false)
        generator.invoke_all
      end

      it "appends Case suffix and includes base attributes" do
        expect(generator).to have_received(:generate).with(
          "flex:model",
          "CaseTestCase",
          "application_form_id:uuid",
          "status:integer",
          "business_process_current_step:string",
          "facts:jsonb",
          "--parent",
          "Flex::Case"
        )
      end
    end

    context "with namespaced case name" do
      let(:name) { "MyModule::TestCase" }

      before do
        allow(generator).to receive(:yes?).and_return(false)
        generator.invoke_all
      end

      it "preserves namespace and handles case suffix with base attributes" do
        expect(generator).to have_received(:generate).with(
          "flex:model",
          "MyModule::TestCase",
          "application_form_id:uuid",
          "status:integer",
          "business_process_current_step:string",
          "facts:jsonb",
          "--parent",
          "Flex::Case"
        )
      end
    end
  end
end
