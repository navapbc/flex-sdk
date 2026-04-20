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
      expect(File.exist?("#{sub_dir}/views.md")).to be true
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

  describe "generating multi_page_form" do
    let(:generator) do
      described_class.new([ "multi_page_form" ], { quiet: true, force: true }, destination_root: destination_root)
    end
    let(:root_file) { "#{destination_root}/.agents/rules/strata-sdk/strata-multi-page-form.md" }
    let(:sub_dir)   { "#{destination_root}/.agents/rules/strata-sdk/strata-multi-page-form" }

    before { generator.invoke_all }

    it "creates the root rule file in default .agents/rules/strata-sdk/" do
      expect(File.exist?(root_file)).to be true
    end

    it "root file is under 12,000 characters" do
      content = File.read(root_file)
      expect(content.length).to be <= 12_000,
        "Root file exceeds 12,000 chars (#{content.length})"
    end

    it "root file has path-scoped frontmatter" do
      content = File.read(root_file)
      expect(content).to start_with("---\n")
      expect(content).to include("paths:")
      expect(content).to include("**/app/flows/**/*_flow.rb")
      expect(content).to include("**/app/models/**/*_form.rb")
      expect(content).to include("**/app/controllers/**/*_forms_controller.rb")
      expect(content).to include("**/app/views/**/*_forms/**/*.html.erb")
    end

    it "root file has expected structure" do
      content = File.read(root_file)
      expect(content).to include("# Strata SDK: Multi-Page Forms")
      expect(content).to include("ApplicationFormFlow")
      expect(content).to include("task")
      expect(content).to include("question_page")
      expect(content.length).to be > 500
    end

    it "root file references sub-files" do
      content = File.read(root_file)
      expect(content).to include("strata-multi-page-form/")
    end

    it "creates a sub-file directory" do
      expect(File.directory?(sub_dir)).to be true
    end

    it "creates expected sub-files" do
      expect(File.exist?("#{sub_dir}/flow-dsl.md")).to be true
      expect(File.exist?("#{sub_dir}/controller-and-routes.md")).to be true
      expect(File.exist?("#{sub_dir}/pages-tasks-validations.md")).to be true
      expect(File.exist?("#{sub_dir}/views-and-locales.md")).to be true
    end

    it "sub-files contain path-scoped frontmatter" do
      Dir.glob("#{sub_dir}/*.md").each do |sub_file|
        content = File.read(sub_file)
        expect(content).to start_with("---\n"),
          "#{File.basename(sub_file)} missing frontmatter"
        expect(content).to include("paths:"),
          "#{File.basename(sub_file)} missing paths in frontmatter"
      end
    end

    it "each sub-file is under 12,000 characters" do
      Dir.glob("#{sub_dir}/*.md").each do |sub_file|
        content = File.read(sub_file)
        expect(content.length).to be <= 12_000,
          "#{File.basename(sub_file)} exceeds 12,000 chars (#{content.length})"
      end
    end

    it "sub-files contain actual source code" do
      combined = Dir.glob("#{sub_dir}/*.md").map { |f| File.read(f) }.join
      expect(combined).to match(/\b(def|class|module)\s+\w+/)
    end

    it "flow-dsl sub-file contains ApplicationFormFlow module" do
      content = File.read("#{sub_dir}/flow-dsl.md")
      expect(content).to include("module ApplicationFormFlow")
    end

    it "controller-and-routes sub-file contains module ApplicationFormController" do
      content = File.read("#{sub_dir}/controller-and-routes.md")
      expect(content).to include("module ApplicationFormController")
    end

    it "controller-and-routes sub-file contains class TaskEvaluator" do
      content = File.read("#{sub_dir}/controller-and-routes.md")
      expect(content).to include("class TaskEvaluator")
    end

    it "pages-tasks-validations sub-file contains class QuestionPage" do
      content = File.read("#{sub_dir}/pages-tasks-validations.md")
      expect(content).to include("class QuestionPage")
    end

    it "pages-tasks-validations sub-file contains class Task" do
      content = File.read("#{sub_dir}/pages-tasks-validations.md")
      expect(content).to include("class Task")
    end

    it "pages-tasks-validations sub-file contains module ApplicationFormValidations" do
      content = File.read("#{sub_dir}/pages-tasks-validations.md")
      expect(content).to include("module ApplicationFormValidations")
    end

    it "views-and-locales sub-file references strata:application_form_views generator" do
      content = File.read("#{sub_dir}/views-and-locales.md")
      expect(content).to include("strata:application_form_views")
    end

    it "creates the recipe sub-file" do
      expect(File.exist?("#{sub_dir}/recipe.md")).to be true
    end

    it "recipe sub-file has path-scoped frontmatter" do
      content = File.read("#{sub_dir}/recipe.md")
      expect(content).to start_with("---\n")
      expect(content).to include("paths:")
      expect(content).to include("**/app/flows/**/*_flow.rb")
      expect(content).to include("**/app/models/**/*_form.rb")
      expect(content).to include("**/app/controllers/**/*_forms_controller.rb")
    end

    it "recipe sub-file has title and overview table" do
      content = File.read("#{sub_dir}/recipe.md")
      expect(content).to include("# Strata SDK: Multi-Page Form — Build Recipe")
      expect(content).to include("| Step | Action |")
    end

    it "recipe Step 1 generates the application form model" do
      content = File.read("#{sub_dir}/recipe.md")
      expect(content).to include("## Step 1: Generate the Application Form Model")
      expect(content).to include("bin/rails generate strata:application_form Leave")
      expect(content).to include("applicant_name:name")
      expect(content).to include("bin/rails db:migrate")
    end

    it "recipe Step 2 defines the flow class by hand" do
      content = File.read("#{sub_dir}/recipe.md")
      expect(content).to include("## Step 2: Hand-Write the Flow Class")
      expect(content).to include("class LeaveApplicationFlow")
      expect(content).to include("include Strata::Flows::ApplicationFormFlow")
      expect(content).to include("task :personal_information")
      expect(content).to include("task :leave_details, depends_on: [:personal_information]")
      expect(content).to include("question_page :applicant_name")
      expect(content).to include("start_page :introduction")
      expect(content).to include("end_page :confirmation")
    end

    it "recipe Step 3 wires per-page validations via Flow constants" do
      content = File.read("#{sub_dir}/recipe.md")
      expect(content).to include("## Step 3: Wire Per-Page Validations")
      expect(content).to include("include Strata::Flows::ApplicationFormValidations")
      expect(content).to include("validate_flow")
      expect(content).to include("on: Flow::")
    end

    it "recipe Step 4 runs the views generator" do
      content = File.read("#{sub_dir}/recipe.md")
      expect(content).to include("## Step 4: Generate Views, Layout, and Locales")
      expect(content).to include("bin/rails generate strata:application_form_views")
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
