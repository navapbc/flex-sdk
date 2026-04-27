# frozen_string_literal: true

require "rails_helper"
require "generators/strata/rules/source_excerpt_helper"
require "fileutils"
require "tmpdir"

require "generators/strata/rules/rules_generator"

RSpec.describe Strata::Generators::RulesGenerator, type: :generator do
  describe "generating attributes" do
    let(:destination_root) { Dir.mktmpdir }
    let(:generator) do
      described_class.new([ "attributes" ], { quiet: true, force: true }, destination_root: destination_root)
    end

    after { FileUtils.rm_rf(destination_root) }

    before { generator.invoke_all }

    it "creates the root rule file in .agents/rules/strata-sdk/" do
      expect(File.exist?("#{destination_root}/.agents/rules/strata-sdk/strata-attributes.md")).to be true
    end

    it "root file is under 12,000 characters" do
      content = File.read("#{destination_root}/.agents/rules/strata-sdk/strata-attributes.md")
      expect(content.length).to be <= 12_000,
        "Root file exceeds 12,000 chars (#{content.length})"
    end

    it "root file has path-scoped frontmatter for all model files" do
      content = File.read("#{destination_root}/.agents/rules/strata-sdk/strata-attributes.md")
      expect(content).to start_with("---\n")
      expect(content).to include("paths:")
      expect(content).to include("**/app/models/**/*.rb")
    end

    it "root file embeds Attributes module source" do
      content = File.read("#{destination_root}/.agents/rules/strata-sdk/strata-attributes.md")
      expect(content).to include("module Attributes")
      expect(content).to include("strata_attribute")
    end

    it "root file embeds migration_generator.rb excerpt" do
      content = File.read("#{destination_root}/.agents/rules/strata-sdk/strata-attributes.md")
      expect(content).to include("get_columns_for_attribute")
    end

    it "root file contains corrected column mapping table" do
      content = File.read("#{destination_root}/.agents/rules/strata-sdk/strata-attributes.md")
      # memorable_date: single :date column (not {attr}_date)
      expect(content).to match(/memorable_date.*\{attr\}:date/m)
      # range: _start/_end columns (not _min/_max)
      expect(content).to match(/range.*_start.*_end/m)
      # year_month: single :string column
      expect(content).to match(/year_month.*:string/m)
      # year_quarter: single :string column
      expect(content).to match(/year_quarter.*:string/m)
    end

    it "root file has sub-rule reference table" do
      content = File.read("#{destination_root}/.agents/rules/strata-sdk/strata-attributes.md")
      expect(content).to include("strata-attributes/")
    end

    it "creates sub-file directory" do
      expect(File.directory?("#{destination_root}/.agents/rules/strata-sdk/strata-attributes")).to be true
    end

    it "creates all 10 user-facing attribute sub-files" do
      sub_dir = "#{destination_root}/.agents/rules/strata-sdk/strata-attributes"
      %w[address name memorable-date money tax-id array us-date range year-month year-quarter].each do |attr|
        expect(File.exist?("#{sub_dir}/#{attr}.md")).to be(true), "Missing sub-file: #{attr}.md"
      end
    end

    it "creates basic-value-object sub-file (base class)" do
      sub_dir = "#{destination_root}/.agents/rules/strata-sdk/strata-attributes"
      expect(File.exist?("#{sub_dir}/basic-value-object.md")).to be true
    end

    it "each sub-file is under 12,000 characters" do
      sub_dir = "#{destination_root}/.agents/rules/strata-sdk/strata-attributes"
      Dir.glob("#{sub_dir}/*.md").each do |sub_file|
        content = File.read(sub_file)
        expect(content.length).to be <= 12_000,
          "#{File.basename(sub_file)} exceeds 12,000 chars (#{content.length})"
      end
    end

    it "each sub-file has frontmatter scoped to all model files" do
      sub_dir = "#{destination_root}/.agents/rules/strata-sdk/strata-attributes"
      Dir.glob("#{sub_dir}/*.md").each do |sub_file|
        content = File.read(sub_file)
        expect(content).to start_with("---\n"),
          "#{File.basename(sub_file)} missing frontmatter"
        expect(content).to include("**/app/models/**/*.rb"),
          "#{File.basename(sub_file)} missing model path scope"
      end
    end

    it "sub-files contain actual source code" do
      sub_dir = "#{destination_root}/.agents/rules/strata-sdk/strata-attributes"
      Dir.glob("#{sub_dir}/*.md").each do |sub_file|
        content = File.read(sub_file)
        expect(content).to match(/\b(def|class|module)\s+\w+/),
          "#{File.basename(sub_file)} contains no source code"
      end
    end

    it "every generated rule file's paths begin with **/ (monorepo-safe)" do
      root_dir = "#{destination_root}/.agents/rules/strata-sdk"
      files = Dir.glob("#{root_dir}/strata-attributes{.md,/**/*.md}")
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
