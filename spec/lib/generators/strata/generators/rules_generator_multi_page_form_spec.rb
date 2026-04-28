# frozen_string_literal: true

require "rails_helper"
require "generators/strata/rules/source_excerpt_helper"
require "fileutils"
require "tmpdir"

require "generators/strata/rules/rules_generator"

RSpec.describe Strata::Generators::RulesGenerator, type: :generator do
  describe "generating multi_page_form" do
    let(:destination_root) { Dir.mktmpdir }
    let(:generator) do
      described_class.new([ "multi_page_form" ], { quiet: true, force: true }, destination_root: destination_root)
    end

    after { FileUtils.rm_rf(destination_root) }

    before { generator.invoke_all }

    it "creates the root rule file in default .agents/rules/strata-sdk/" do
      expect(File.exist?("#{destination_root}/.agents/rules/strata-sdk/strata-multi-page-form.md")).to be true
    end

    it "creates all 5 sub-files" do
      sub_dir = "#{destination_root}/.agents/rules/strata-sdk/strata-multi-page-form"
      expect(File.exist?("#{sub_dir}/recipe.md")).to be true
      expect(File.exist?("#{sub_dir}/flow-dsl.md")).to be true
      expect(File.exist?("#{sub_dir}/controller-and-routes.md")).to be true
      expect(File.exist?("#{sub_dir}/pages-tasks-validations.md")).to be true
      expect(File.exist?("#{sub_dir}/views-and-locales.md")).to be true
    end

    it "each rendered file is under 12,000 characters" do
      root_file = "#{destination_root}/.agents/rules/strata-sdk/strata-multi-page-form.md"
      content = File.read(root_file)
      expect(content.length).to be <= 12_000,
        "Root file exceeds 12,000 chars (#{content.length})"

      sub_dir = "#{destination_root}/.agents/rules/strata-sdk/strata-multi-page-form"
      Dir.glob("#{sub_dir}/*.md").each do |sub_file|
        content = File.read(sub_file)
        expect(content.length).to be <= 12_000,
          "#{File.basename(sub_file)} exceeds 12,000 chars (#{content.length})"
      end
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

    it "recipe sub-file contains step headings 1 through 8" do
      content = File.read("#{destination_root}/.agents/rules/strata-sdk/strata-multi-page-form/recipe.md")
      (1..8).each do |step|
        expect(content).to include("## Step #{step}:"),
          "recipe.md missing '## Step #{step}:'"
      end
    end

    it "recipe sub-file cross-references strata-application-form/recipe.md (Step 1 chain)" do
      content = File.read("#{destination_root}/.agents/rules/strata-sdk/strata-multi-page-form/recipe.md")
      expect(content).to include("strata-application-form/recipe.md")
    end

    it "recipe sub-file does not contain stale strata-application-form/attributes.md reference" do
      content = File.read("#{destination_root}/.agents/rules/strata-sdk/strata-multi-page-form/recipe.md")
      expect(content).not_to include("strata-application-form/attributes.md")
    end

    it "views-and-locales sub-file does not scope to bare config/locales/**/*.yml" do
      content = File.read("#{destination_root}/.agents/rules/strata-sdk/strata-multi-page-form/views-and-locales.md")
      expect(content).not_to include('**/config/locales/**/*.yml')
    end
  end

  describe "generating application_form (determinable path scope regression)" do
    let(:destination_root) { Dir.mktmpdir }
    let(:generator) do
      described_class.new([ "application_form" ], { quiet: true, force: true }, destination_root: destination_root)
    end

    after { FileUtils.rm_rf(destination_root) }

    before { generator.invoke_all }

    it "determinable sub-file path scope does not contain bare *form*.rb" do
      content = File.read("#{destination_root}/.agents/rules/strata-sdk/strata-application-form/determinable.md")
      frontmatter = content[/\A---\n(.*?)\n---/m, 1]
      path_entries = frontmatter.scan(/^\s*-\s*"([^"]+)"/).flatten
      expect(path_entries).not_to include(a_string_matching(/\*form\*\.rb$/)),
        "determinable.md path scope should not match bare *form*.rb — too broad"
    end
  end
end
