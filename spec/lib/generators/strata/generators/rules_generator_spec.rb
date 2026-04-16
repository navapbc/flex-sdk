# frozen_string_literal: true

require "rails_helper"
require "generators/strata/rules/source_excerpt_helper"
require "fileutils"
require "tmpdir"

RSpec.describe Strata::Generators::SourceExcerptHelper do
  let(:helper) { Class.new { include Strata::Generators::SourceExcerptHelper }.new }

  describe "#sdk_root" do
    it "returns Strata::Engine.root" do
      expect(helper.sdk_root).to eq(Strata::Engine.root)
    end
  end

  describe "#read_sdk_file" do
    it "reads an existing SDK file" do
      content = helper.read_sdk_file("app/models/strata/application_form.rb")
      expect(content).to include("class ApplicationForm")
    end

    it "raises for nonexistent files" do
      expect { helper.read_sdk_file("nonexistent.rb") }.to raise_error(/not found/)
    end
  end

  describe "#excerpt_doc_section" do
    it "extracts a section from a markdown doc" do
      result = helper.excerpt_doc_section("intake-application-forms.md", "What is an Application Form?")
      expect(result).to include("Application forms implement")
    end

    it "stops at the next heading of same or higher level" do
      result = helper.excerpt_doc_section("intake-application-forms.md", "What is an Application Form?")
      expect(result).not_to include("## Key Concepts")
    end

    it "raises for nonexistent doc" do
      expect { helper.excerpt_doc_section("nonexistent.md", "Heading") }.to raise_error(/not found/)
    end

    it "returns empty string for nonexistent heading" do
      result = helper.excerpt_doc_section("intake-application-forms.md", "Nonexistent Heading")
      expect(result).to eq("")
    end
  end
end
