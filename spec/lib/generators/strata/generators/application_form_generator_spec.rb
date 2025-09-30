require 'rails_helper'
require 'generators/strata/application_form/application_form_generator'
require 'fileutils'
require 'tmpdir'

RSpec.describe Strata::Generators::ApplicationFormGenerator, type: :generator do
  let(:destination_root) { Dir.mktmpdir }
  let(:generator) { described_class.new([ name ], options, destination_root: destination_root) }
  let(:name) { 'TestForm' }
  let(:options) { {} }

  before do
    FileUtils.mkdir_p("#{destination_root}/app/models/strata")
    FileUtils.mkdir_p("#{destination_root}/spec/models/strata")
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
          expect(generator).to have_received(:generate).with("strata:model", expected_name, "user_id:uuid", "status:integer", "submitted_at:datetime", "--parent", "Strata::ApplicationForm")
        end
      end
    end
  end

  describe "parent class handling" do
    context "when no parent option is provided" do
      it "defaults to Strata::ApplicationForm" do
        generator.create_application_form
        expect(generator).to have_received(:generate).with("strata:model", "TestFormApplicationForm", "user_id:uuid", "status:integer", "submitted_at:datetime", "--parent", "Strata::ApplicationForm")
      end
    end

    context "when custom parent option is provided" do
      let(:options) { { parent: "CustomApplicationForm" } }

      it "uses the custom parent class" do
        generator.create_application_form
        expect(generator).to have_received(:generate).with("strata:model", "TestFormApplicationForm", "user_id:uuid", "status:integer", "submitted_at:datetime", "--parent", "CustomApplicationForm")
      end
    end

    context "when parent is an empty string" do
      let(:options) { { parent: "" } }

      it "defaults to Strata::ApplicationForm" do
        generator.create_application_form
        expect(generator).to have_received(:generate).with("strata:model", "TestFormApplicationForm", "user_id:uuid", "status:integer", "submitted_at:datetime", "--parent", "Strata::ApplicationForm")
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
        expect(generator).to have_received(:generate).with("strata:model", "TestFormApplicationForm", "user_id:uuid", "status:integer", "submitted_at:datetime", "name:string", "email:string", "--parent", "Strata::ApplicationForm")
      end
    end

    context "with custom parent and attributes" do
      let(:options) { { parent: "CustomForm" } }

      it "passes through both parent and attributes" do
        generator.create_application_form
        expect(generator).to have_received(:generate).with("strata:model", "TestFormApplicationForm", "user_id:uuid", "status:integer", "submitted_at:datetime", "name:string", "email:string", "--parent", "CustomForm")
      end
    end
  end

  describe "edge cases" do
    context "with name ending in different case" do
      let(:name) { "TestApplicationform" }

      it "still appends ApplicationForm suffix" do
        generator.create_application_form
        expect(generator).to have_received(:generate).with("strata:model", "TestApplicationformApplicationForm", "user_id:uuid", "status:integer", "submitted_at:datetime", "--parent", "Strata::ApplicationForm")
      end
    end

    context "with name containing ApplicationForm in middle" do
      let(:name) { "ApplicationFormTest" }

      it "appends ApplicationForm suffix" do
        generator.create_application_form
        expect(generator).to have_received(:generate).with("strata:model", "ApplicationFormTestApplicationForm", "user_id:uuid", "status:integer", "submitted_at:datetime", "--parent", "Strata::ApplicationForm")
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
      expect(generator).to have_received(:generate).with("strata:model", "TestIntegrationApplicationForm", "user_id:uuid", "status:integer", "submitted_at:datetime", "--parent", "Strata::ApplicationForm")
    end

    context "with custom parent and attributes" do
      let(:generator) { described_class.new([ 'TestIntegration', 'name:string' ], { parent: 'CustomParent' }, destination_root: destination_root) }

      before do
        allow(generator).to receive(:generate)
      end

      it "passes all options correctly to Rails generator" do
        generator.invoke_all
        expect(generator).to have_received(:generate).with("strata:model", "TestIntegrationApplicationForm", "user_id:uuid", "status:integer", "submitted_at:datetime", "name:string", "--parent", "CustomParent")
      end
    end

    context "with name already having ApplicationForm suffix" do
      let(:generator) { described_class.new([ 'TestApplicationForm' ], {}, destination_root: destination_root) }

      before do
        allow(generator).to receive(:generate)
      end

      it "does not double-append the suffix" do
        generator.invoke_all
        expect(generator).to have_received(:generate).with("strata:model", "TestApplicationForm", "user_id:uuid", "status:integer", "submitted_at:datetime", "--parent", "Strata::ApplicationForm")
      end
    end
  end

  describe "attribute conflict handling" do
    let(:generator) { described_class.new([ name, "user_id:string", "status:string", "name:string" ], options, destination_root: destination_root) }

    before do
      allow(generator).to receive(:generate)
    end

    it "base attributes take precedence over user attributes" do
      generator.create_application_form
      expect(generator).to have_received(:generate).with("strata:model", "TestFormApplicationForm", "user_id:uuid", "status:integer", "submitted_at:datetime", "name:string", "--parent", "Strata::ApplicationForm")
    end
  end
end
