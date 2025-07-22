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

      it "transforms 'Passport' to 'PassportCase'" do
        expect(generator).to have_received(:generate).with("flex:model", "PassportCase", "--parent", "Flex::Case")
      end
    end

    context "with name already having Case suffix" do
      let(:name) { "PassportCase" }

      before do
        allow(generator).to receive(:yes?).and_return(false)
        generator.invoke_all
      end

      it "keeps 'PassportCase' as 'PassportCase'" do
        expect(generator).to have_received(:generate).with("flex:model", "PassportCase", "--parent", "Flex::Case")
      end
    end

    context "with mixed case name" do
      let(:name) { "BenefitsApplication" }

      before do
        allow(generator).to receive(:yes?).and_return(false)
        generator.invoke_all
      end

      it "transforms 'BenefitsApplication' to 'BenefitsApplicationCase'" do
        expect(generator).to have_received(:generate).with("flex:model", "BenefitsApplicationCase", "--parent", "Flex::Case")
      end
    end

    context "with single word" do
      let(:name) { "Review" }

      before do
        allow(generator).to receive(:yes?).and_return(false)
        generator.invoke_all
      end

      it "transforms 'Review' to 'ReviewCase'" do
        expect(generator).to have_received(:generate).with("flex:model", "ReviewCase", "--parent", "Flex::Case")
      end
    end

    context "with lowercase name" do
      let(:name) { "document" }

      before do
        allow(generator).to receive(:yes?).and_return(false)
        generator.invoke_all
      end

      it "transforms 'document' to 'DocumentCase'" do
        expect(generator).to have_received(:generate).with("flex:model", "DocumentCase", "--parent", "Flex::Case")
      end
    end
  end

  describe "attribute handling" do
    context "with no attributes" do
      before do
        allow(generator).to receive(:yes?).and_return(false)
        generator.invoke_all
      end

      it "passes only the case name and parent" do
        expect(generator).to have_received(:generate).with("flex:model", "TestCase", "--parent", "Flex::Case")
      end
    end

    context "with standard attributes" do
      let(:attributes) { [ "name:string", "email:string" ] }

      before do
        allow(generator).to receive(:yes?).and_return(false)
        generator.invoke_all
      end

      it "passes through attributes to model generator" do
        expect(generator).to have_received(:generate).with("flex:model", "TestCase", "name:string", "email:string", "--parent", "Flex::Case")
      end
    end

    context "with flex attributes" do
      let(:attributes) { [ "applicant_name:name", "home_address:address" ] }

      before do
        allow(generator).to receive(:yes?).and_return(false)
        generator.invoke_all
      end

      it "passes through flex attributes to model generator" do
        expect(generator).to have_received(:generate).with("flex:model", "TestCase", "applicant_name:name", "home_address:address", "--parent", "Flex::Case")
      end
    end

    context "with mixed attributes" do
      let(:attributes) { [ "status:string", "applicant_name:name", "priority:integer" ] }

      before do
        allow(generator).to receive(:yes?).and_return(false)
        generator.invoke_all
      end

      it "passes through all attributes to model generator" do
        expect(generator).to have_received(:generate).with("flex:model", "TestCase", "status:string", "applicant_name:name", "priority:integer", "--parent", "Flex::Case")
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

      it "adds type:string attribute" do
        expect(generator).to have_received(:generate).with("flex:model", "TestCase", "type:string", "--parent", "Flex::Case")
      end
    end

    context "with --sti flag and other attributes" do
      let(:attributes) { [ "name:string" ] }
      let(:options) { { sti: true } }

      before do
        allow(generator).to receive(:yes?).and_return(false)
        generator.invoke_all
      end

      it "adds type:string attribute along with other attributes" do
        expect(generator).to have_received(:generate).with("flex:model", "TestCase", "name:string", "type:string", "--parent", "Flex::Case")
      end
    end

    context "without --sti flag" do
      before do
        allow(generator).to receive(:yes?).and_return(false)
        generator.invoke_all
      end

      it "does not add type attribute" do
        expect(generator).to have_received(:generate).with("flex:model", "TestCase", "--parent", "Flex::Case")
      end
    end
  end

  describe "business process integration" do
    describe "when business process exists" do
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

    describe "when business process does not exist and user declines" do
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

    describe "when business process does not exist and user agrees" do
      before do
        hide_const("TestBusinessProcess")
        allow(generator).to receive(:yes?).and_return(true)
        generator.invoke_all
      end

      it "prompts user once" do
        expect(generator).to have_received(:yes?).with("Business process TestBusinessProcess does not exist. Generate it? (y/n)").once
      end

      it "generates business process" do
        expect(generator).to have_received(:generate).with("flex:business_process", "Test").once
      end
    end

    describe "with custom business process name" do
      let(:options) { { business_process_name: "CustomBusinessProcess" } }

      before do
        allow(generator).to receive(:yes?).and_return(true)
        generator.create_case_model
      end

      it "uses custom business process name" do
        expect(generator).to have_received(:yes?).with("Business process CustomBusinessProcess does not exist. Generate it? (y/n)")
        expect(generator).to have_received(:generate).with("flex:business_process", "CustomBusinessProcess")
      end
    end

    describe "with --skip_business_process flag" do
      let(:options) { { skip_business_process: true } }

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
    describe "when application form exists" do
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

    describe "when application form does not exist and user declines" do
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

    describe "when application form does not exist and user agrees" do
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

    describe "with custom application form name" do
      let(:options) { { application_form_name: "CustomApplicationForm" } }

      before do
        allow(generator).to receive(:yes?).and_return(true)
        generator.create_case_model
      end

      it "uses custom application form name" do
        expect(generator).to have_received(:yes?).with("Application form CustomApplicationForm does not exist. Generate it? (y/n)")
        expect(generator).to have_received(:generate).with("flex:application_form", "CustomApplicationForm")
      end
    end

    describe "with --skip_application_form flag" do
      let(:options) { { skip_application_form: true } }

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

  describe "combined scenarios" do
    context "with both business process and application form missing, user agrees to both" do
      before do
        hide_const("TestBusinessProcess")
        hide_const("TestApplicationForm")
        allow(generator).to receive(:yes?).and_return(true)
        generator.invoke_all
      end

      it "generates both business process and application form" do
        expect(generator).to have_received(:generate).with("flex:business_process", "Test").once
        expect(generator).to have_received(:generate).with("flex:application_form", "Test").once
        expect(generator).to have_received(:generate).with("flex:model", "TestCase", "--parent", "Flex::Case").once
      end
    end

    context "with custom names for both business process and application form" do
      let(:options) { { business_process_name: "CustomBP", application_form_name: "CustomAF" } }

      before do
        allow(generator).to receive(:yes?).and_return(true)
        generator.invoke_all
      end

      it "uses custom names for both" do
        expect(generator).to have_received(:generate).with("flex:business_process", "CustomBP").once
        expect(generator).to have_received(:generate).with("flex:application_form", "CustomAF").once
      end
    end

    context "with all options combined" do
      let(:attributes) { [ "name:string", "address:address" ] }
      let(:options) { { sti: true, business_process_name: "CustomBP", application_form_name: "CustomAF" } }

      before do
        allow(generator).to receive(:yes?).and_return(true)
        generator.invoke_all
      end

      it "handles all options correctly" do
        expect(generator).to have_received(:generate).with("flex:business_process", "CustomBP").once
        expect(generator).to have_received(:generate).with("flex:application_form", "CustomAF").once
        expect(generator).to have_received(:generate).with("flex:model", "TestCase", "name:string", "address:address", "type:string", "--parent", "Flex::Case").once
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

      it "still appends Case suffix" do
        expect(generator).to have_received(:generate).with("flex:model", "TestCASECase", "--parent", "Flex::Case")
      end
    end

    context "with name containing Case in middle" do
      let(:name) { "CaseTest" }

      before do
        allow(generator).to receive(:yes?).and_return(false)
        generator.invoke_all
      end

      it "appends Case suffix" do
        expect(generator).to have_received(:generate).with("flex:model", "CaseTestCase", "--parent", "Flex::Case")
      end
    end

    context "with namespaced case name" do
      let(:name) { "MyModule::TestCase" }

      before do
        allow(generator).to receive(:yes?).and_return(false)
        generator.invoke_all
      end

      it "preserves namespace and handles case suffix" do
        expect(generator).to have_received(:generate).with("flex:model", "MyModule::TestCase", "--parent", "Flex::Case")
      end
    end
  end
end
