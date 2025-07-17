require 'rails_helper'
require 'generators/flex/application_form/application_form_generator'
require 'fileutils'
require 'tmpdir'

RSpec.describe Flex::Generators::ApplicationFormGenerator, type: :generator do
  let(:destination_root) { Dir.mktmpdir }
  let(:generator) { described_class.new([ name ], options, destination_root: destination_root) }
  let(:name) { 'TestForm' }
  let(:options) { {} }

  before do
    FileUtils.mkdir_p("#{destination_root}/app/models/flex")
    FileUtils.mkdir_p("#{destination_root}/spec/models/flex")
    allow(generator).to receive(:generate)
  end

  after do
    FileUtils.rm_rf(destination_root)
  end

  describe "name transformation" do
    [
      [ "basic name", "Kitty", "KittyApplicationForm" ],
      [ "name with ApplicationForm suffix", "KittyApplicationForm", "KittyApplicationForm" ],
      [ "mixed case name", "PassportRequest", "PassportRequestApplicationForm" ],
      [ "single word", "Benefits", "BenefitsApplicationForm" ]
    ].each do |description, input_name, expected_name|
      context "with #{description}" do
        let(:name) { input_name }

        it "transforms '#{input_name}' to '#{expected_name}'" do
          generator.create_application_form
          expect(generator).to have_received(:generate).with("flex:model", expected_name, "--parent", "Flex::ApplicationForm")
        end
      end
    end
  end

  describe "parent class handling" do
    context "when no parent option is provided" do
      it "defaults to Flex::ApplicationForm" do
        generator.create_application_form
        expect(generator).to have_received(:generate).with("flex:model", "TestFormApplicationForm", "--parent", "Flex::ApplicationForm")
      end
    end

    context "when custom parent option is provided" do
      let(:options) { { parent: "CustomApplicationForm" } }

      it "uses the custom parent class" do
        generator.create_application_form
        expect(generator).to have_received(:generate).with("flex:model", "TestFormApplicationForm", "--parent", "CustomApplicationForm")
      end
    end

    context "when parent is an empty string" do
      let(:options) { { parent: "" } }

      it "defaults to Flex::ApplicationForm" do
        generator.create_application_form
        expect(generator).to have_received(:generate).with("flex:model", "TestFormApplicationForm", "--parent", "Flex::ApplicationForm")
      end
    end
  end

  describe "argument pass-through" do
    let(:generator) { described_class.new([ name, "name:string", "email:string" ], options, destination_root: destination_root) }

    before do
      allow(generator).to receive(:generate)
    end

    context "with additional attributes" do
      it "passes through additional arguments to model generator" do
        generator.create_application_form
        expect(generator).to have_received(:generate).with("flex:model", "TestFormApplicationForm", "--parent", "Flex::ApplicationForm", "name:string", "email:string")
      end
    end

    context "with custom parent and attributes" do
      let(:options) { { parent: "CustomForm" } }

      it "passes through both parent and attributes" do
        generator.create_application_form
        expect(generator).to have_received(:generate).with("flex:model", "TestFormApplicationForm", "--parent", "CustomForm", "name:string", "email:string")
      end
    end
  end

  describe "edge cases" do
    context "with name ending in different case" do
      let(:name) { "TestApplicationform" }

      it "still appends ApplicationForm suffix" do
        generator.create_application_form
        expect(generator).to have_received(:generate).with("flex:model", "TestApplicationformApplicationForm", "--parent", "Flex::ApplicationForm")
      end
    end

    context "with name containing ApplicationForm in middle" do
      let(:name) { "ApplicationFormTest" }

      it "appends ApplicationForm suffix" do
        generator.create_application_form
        expect(generator).to have_received(:generate).with("flex:model", "ApplicationFormTestApplicationForm", "--parent", "Flex::ApplicationForm")
      end
    end
  end

  describe "integration tests" do
    let(:generator) { described_class.new([ 'TestIntegration' ], {}, destination_root: destination_root) }

    before do
      allow(generator).to receive(:generate).and_call_original
    end

    it "actually invokes the Rails model generator" do
      allow(generator).to receive(:generate)
      generator.invoke_all
      expect(generator).to have_received(:generate).with("flex:model", "TestIntegrationApplicationForm", "--parent", "Flex::ApplicationForm")
    end

    context "with custom parent and attributes" do
      let(:generator) { described_class.new([ 'TestIntegration', 'name:string' ], { parent: 'CustomParent' }, destination_root: destination_root) }

      before do
        allow(generator).to receive(:generate)
      end

      it "passes all options correctly to Rails generator" do
        generator.invoke_all
        expect(generator).to have_received(:generate).with("flex:model", "TestIntegrationApplicationForm", "--parent", "CustomParent", "name:string")
      end
    end

    context "with name already having ApplicationForm suffix" do
      let(:generator) { described_class.new([ 'TestApplicationForm' ], {}, destination_root: destination_root) }

      before do
        allow(generator).to receive(:generate)
      end

      it "does not double-append the suffix" do
        generator.invoke_all
        expect(generator).to have_received(:generate).with("flex:model", "TestApplicationForm", "--parent", "Flex::ApplicationForm")
      end
    end
  end
end
