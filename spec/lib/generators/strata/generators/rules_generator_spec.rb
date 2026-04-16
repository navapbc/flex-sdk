# frozen_string_literal: true

require "rails_helper"
require "generators/strata/rules/source_excerpt_helper"
require "fileutils"
require "tmpdir"

require "generators/strata/rules/rules_generator"

RSpec.describe Strata::Generators::RulesGenerator, type: :generator do
  let(:destination_root) { Dir.mktmpdir }

  after { FileUtils.rm_rf(destination_root) }

  describe Strata::Generators::SourceExcerptHelper do
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

  describe "generating application_form" do
    let(:generator) do
      described_class.new([ "application_form" ], { quiet: true, force: true }, destination_root: destination_root)
    end

    before { generator.invoke_all }

    it "creates the root rule file in default .agents/rules/strata-sdk/" do
      expect(File.exist?("#{destination_root}/.agents/rules/strata-sdk/strata-application-form.md")).to be true
    end

    it "root file is under 12,000 characters" do
      content = File.read("#{destination_root}/.agents/rules/strata-sdk/strata-application-form.md")
      expect(content.length).to be <= 12_000,
        "Root file exceeds 12,000 chars (#{content.length})"
    end

    it "root file has path-scoped frontmatter" do
      content = File.read("#{destination_root}/.agents/rules/strata-sdk/strata-application-form.md")
      expect(content).to start_with("---\n")
      expect(content).to include("paths:")
      expect(content).to include("app/models/**/*application_form*.rb")
      expect(content).to include("app/controllers/**/*application_forms*.rb")
    end

    it "root file has expected structure" do
      content = File.read("#{destination_root}/.agents/rules/strata-sdk/strata-application-form.md")
      expect(content).to include("# Strata SDK: Application Forms")
      expect(content).to include("ApplicationForm")
      expect(content).to include("strata_attribute")
      expect(content.length).to be > 500
    end

    it "root file references sub-files" do
      content = File.read("#{destination_root}/.agents/rules/strata-sdk/strata-application-form.md")
      expect(content).to include("strata-application-form/")
    end

    it "creates a sub-file directory" do
      sub_dir = "#{destination_root}/.agents/rules/strata-sdk/strata-application-form"
      expect(File.directory?(sub_dir)).to be true
    end

    it "creates expected sub-files" do
      sub_dir = "#{destination_root}/.agents/rules/strata-sdk/strata-application-form"
      expect(File.exist?("#{sub_dir}/core-class.md")).to be true
      expect(File.exist?("#{sub_dir}/attributes.md")).to be true
      expect(File.exist?("#{sub_dir}/determinable.md")).to be true
    end

    it "sub-files contain path-scoped frontmatter" do
      sub_dir = "#{destination_root}/.agents/rules/strata-sdk/strata-application-form"
      Dir.glob("#{sub_dir}/*.md").each do |sub_file|
        content = File.read(sub_file)
        expect(content).to start_with("---\n"),
          "#{File.basename(sub_file)} missing frontmatter"
        expect(content).to include("paths:"),
          "#{File.basename(sub_file)} missing paths in frontmatter"
      end
    end

    it "sub-files contain actual source code" do
      sub_dir = "#{destination_root}/.agents/rules/strata-sdk/strata-application-form"
      combined = Dir.glob("#{sub_dir}/*.md").map { |f| File.read(f) }.join
      expect(combined).to match(/\b(def|class|module)\s+\w+/)
    end

    it "each sub-file is under 12,000 characters" do
      sub_dir = "#{destination_root}/.agents/rules/strata-sdk/strata-application-form"
      Dir.glob("#{sub_dir}/*.md").each do |sub_file|
        content = File.read(sub_file)
        expect(content.length).to be <= 12_000,
          "#{File.basename(sub_file)} exceeds 12,000 chars (#{content.length})"
      end
    end

    it "core-class sub-file contains ApplicationForm source" do
      content = File.read("#{destination_root}/.agents/rules/strata-sdk/strata-application-form/core-class.md")
      expect(content).to include("class ApplicationForm < ApplicationRecord")
      expect(content).to include("def submit_application")
    end

    it "attributes sub-file contains Attributes module source" do
      content = File.read("#{destination_root}/.agents/rules/strata-sdk/strata-application-form/attributes.md")
      expect(content).to include("module Attributes")
      expect(content).to include("strata_attribute")
    end

    it "determinable sub-file contains Determinable source" do
      content = File.read("#{destination_root}/.agents/rules/strata-sdk/strata-application-form/determinable.md")
      expect(content).to include("module Determinable")
      expect(content).to include("record_determination!")
    end
  end

  describe "generating all features" do
    let(:generator) do
      described_class.new([ "all" ], { quiet: true, force: true }, destination_root: destination_root)
    end

    before { generator.invoke_all }

    it "creates a root rule file for each supported feature" do
      described_class::SUPPORTED_FEATURES.each do |feature|
        path = "#{destination_root}/.agents/rules/strata-sdk/strata-#{feature.dasherize}.md"
        expect(File.exist?(path)).to be(true), "Missing root rule for #{feature}"
      end
    end
  end

  describe "--agent flag" do
    {
      "claude" => ".claude/rules",
      "cursor" => ".cursor/rules",
      "copilot" => ".copilot/rules"
    }.each do |agent, expected_dir|
      context "with --agent #{agent}" do
        let(:generator) do
          described_class.new(
            [ "application_form" ],
            { quiet: true, force: true, agent: agent },
            destination_root: destination_root
          )
        end

        before { generator.invoke_all }

        it "writes root file to #{expected_dir}/strata-sdk/" do
          expect(File.exist?("#{destination_root}/#{expected_dir}/strata-sdk/strata-application-form.md")).to be true
        end

        it "writes sub-files to #{expected_dir}/strata-sdk/strata-application-form/" do
          expect(File.exist?("#{destination_root}/#{expected_dir}/strata-sdk/strata-application-form/core-class.md")).to be true
        end
      end
    end

    context "with no --agent flag" do
      let(:generator) do
        described_class.new([ "application_form" ], { quiet: true, force: true }, destination_root: destination_root)
      end

      before { generator.invoke_all }

      it "defaults to .agents/rules/strata-sdk/" do
        expect(File.exist?("#{destination_root}/.agents/rules/strata-sdk/strata-application-form.md")).to be true
      end
    end
  end

  describe "git root detection" do
    let(:project_root) { Dir.mktmpdir }
    let(:rails_app_dir) { File.join(project_root, "app") }

    before do
      FileUtils.mkdir_p(File.join(project_root, ".git"))
      FileUtils.mkdir_p(rails_app_dir)
    end

    after { FileUtils.rm_rf(project_root) }

    it "writes rules to the git root, not the Rails app subdirectory" do
      generator = described_class.new(
        [ "application_form" ],
        { quiet: true, force: true },
        destination_root: rails_app_dir
      )
      generator.invoke_all

      expect(File.exist?("#{project_root}/.agents/rules/strata-sdk/strata-application-form.md")).to be true
      expect(File.exist?("#{rails_app_dir}/.agents/rules/strata-sdk/strata-application-form.md")).to be false
    end

    it "falls back to destination_root when no .git found" do
      no_git_dir = Dir.mktmpdir
      generator = described_class.new(
        [ "application_form" ],
        { quiet: true, force: true },
        destination_root: no_git_dir
      )
      generator.invoke_all

      expect(File.exist?("#{no_git_dir}/.agents/rules/strata-sdk/strata-application-form.md")).to be true
      FileUtils.rm_rf(no_git_dir)
    end
  end

  describe "invalid feature name" do
    it "raises an error" do
      generator = described_class.new([ "nonexistent" ], { quiet: true }, destination_root: destination_root)
      expect { generator.invoke_all }.to raise_error(Thor::Error, /Unknown feature/)
    end
  end

  describe "force overwrite" do
    let(:rule_path) { "#{destination_root}/.agents/rules/strata-sdk/strata-application-form.md" }

    it "overwrites existing files on re-run" do
      generator = described_class.new([ "application_form" ], { quiet: true, force: true }, destination_root: destination_root)
      generator.invoke_all

      original_content = File.read(rule_path)

      # Tamper with the file
      File.write(rule_path, "tampered content")

      # Re-run
      generator2 = described_class.new([ "application_form" ], { quiet: true, force: true }, destination_root: destination_root)
      generator2.invoke_all

      expect(File.read(rule_path)).to eq(original_content)
    end
  end

  describe "source reference validation" do
    described_class::SOURCE_REFERENCES.each do |feature, refs|
      context "with #{feature} references" do
        refs[:files].each do |file_path|
          it "references existing file: #{file_path}" do
            full_path = Strata::Engine.root.join(file_path)
            expect(File.exist?(full_path)).to be(true),
              "Template references missing file: #{file_path}"
          end
        end
      end
    end
  end
end
