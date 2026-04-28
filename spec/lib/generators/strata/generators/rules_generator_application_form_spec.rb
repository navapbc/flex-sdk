# frozen_string_literal: true

require "rails_helper"
require "generators/strata/rules/source_excerpt_helper"
require "fileutils"
require "tmpdir"

require "generators/strata/rules/rules_generator"

RSpec.describe Strata::Generators::RulesGenerator, type: :generator do
  describe "generating application_form" do
    let(:destination_root) { Dir.mktmpdir }
    let(:generator) do
      described_class.new([ "application_form" ], { quiet: true, force: true }, destination_root: destination_root)
    end

    after { FileUtils.rm_rf(destination_root) }

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
      expect(File.exist?("#{sub_dir}/determinable.md")).to be true
      expect(File.exist?("#{sub_dir}/views.md")).to be true
    end

    it "does not create attributes sub-file (moved to strata:rules attributes)" do
      sub_dir = "#{destination_root}/.agents/rules/strata-sdk/strata-application-form"
      expect(File.exist?("#{sub_dir}/attributes.md")).to be false
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

    it "root file points to strata-attributes.md for attribute reference" do
      content = File.read("#{destination_root}/.agents/rules/strata-sdk/strata-application-form.md")
      expect(content).to include("strata-attributes.md")
    end

    it "determinable sub-file contains Determinable source" do
      content = File.read("#{destination_root}/.agents/rules/strata-sdk/strata-application-form/determinable.md")
      expect(content).to include("module Determinable")
      expect(content).to include("record_determination!")
    end

    it "views sub-file contains embedded view source" do
      content = File.read("#{destination_root}/.agents/rules/strata-sdk/strata-application-form/views.md")
      expect(content).to include("strata_form_with")
      expect(content).to include("strata/shared/form_buttons")
      expect(content).to include("strata/shared/step_indicator")
      expect(content).to include("usa-breadcrumb")
    end

    it "views sub-file is scoped to view paths" do
      content = File.read("#{destination_root}/.agents/rules/strata-sdk/strata-application-form/views.md")
      expect(content).to start_with("---\n")
      expect(content).to include("app/views/**/*application_form")
    end

    it "creates the recipe sub-file" do
      sub_dir = "#{destination_root}/.agents/rules/strata-sdk/strata-application-form"
      expect(File.exist?("#{sub_dir}/recipe.md")).to be true
    end

    it "recipe sub-file has path-scoped frontmatter" do
      content = File.read("#{destination_root}/.agents/rules/strata-sdk/strata-application-form/recipe.md")
      expect(content).to start_with("---\n")
      expect(content).to include("paths:")
      expect(content).to include("app/models/**/*application_form*.rb")
    end

    it "recipe sub-file has title and overview table" do
      content = File.read("#{destination_root}/.agents/rules/strata-sdk/strata-application-form/recipe.md")
      expect(content).to include("# Strata SDK: ApplicationForm — Build Recipe")
      expect(content).to include("| Step | Action |")
    end

    it "recipe sub-file has Step 1 (generate model) and Step 2 (test model)" do
      content = File.read("#{destination_root}/.agents/rules/strata-sdk/strata-application-form/recipe.md")
      expect(content).to include("## Step 1: Generate Application Form Model")
      expect(content).to include("bin/rails generate strata:application_form")
      expect(content).to include("## Step 2: Test Model")
      expect(content).to include("publish_event_with_payload")
    end

    it "recipe sub-file has Step 3 (controller) and Step 4 (request spec)" do
      content = File.read("#{destination_root}/.agents/rules/strata-sdk/strata-application-form/recipe.md")
      expect(content).to include("## Step 3: Generate Controller and Routes")
      expect(content).to include("bin/rails generate controller")
      expect(content).to include("## Step 4: Test Controller")
      expect(content).to include('type: :request')
    end

    it "recipe sub-file has Step 5 (views) and Step 6 (view spec) and Recap" do
      content = File.read("#{destination_root}/.agents/rules/strata-sdk/strata-application-form/recipe.md")
      expect(content).to include("## Step 5: Build Views")
      expect(content).to include("strata_form_with")
      expect(content).to include("## Step 6: Test Views")
      expect(content).to include("type: :system")
      expect(content).to include("## Recap")
    end

    it "root file points to recipe as the build entry point" do
      content = File.read("#{destination_root}/.agents/rules/strata-sdk/strata-application-form.md")
      expect(content).to include("Build Recipe")
      expect(content).to include("strata-application-form/recipe.md")
    end

    it "every generated rule file's paths begin with **/ (monorepo-safe)" do
      root_dir = "#{destination_root}/.agents/rules/strata-sdk"
      files = Dir.glob("#{root_dir}/**/*.md")
      expect(files).not_to be_empty

      files.each do |path|
        content = File.read(path)
        frontmatter = content[/\A---\n(.*?)\n---/m, 1]
        expect(frontmatter).not_to be_nil, "#{path} missing frontmatter"

        path_entries = frontmatter.scan(/^\s*-\s*"([^"]+)"/).flatten
        expect(path_entries).not_to be_empty, "#{path} has no path entries"

        expect(path_entries).to all(start_with("**/")),
          "#{path} has path entries not starting with **/ for monorepo scoping"
      end
    end
  end
end
