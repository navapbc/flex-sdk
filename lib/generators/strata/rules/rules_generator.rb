# frozen_string_literal: true

require "rails/generators"
require "erb"
require_relative "source_excerpt_helper"

module Strata
  module Generators
    # Generates path-scoped agent rule files for Strata SDK features.
    # Rules embed current SDK source code so re-running the generator
    # updates rules to match the installed SDK version.
    class RulesGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)
      include SourceExcerptHelper

      SUPPORTED_FEATURES = %w[application_form].freeze

      # Manifest of all SDK source files referenced by templates.
      # Specs validate these paths still exist, catching drift when
      # SDK files are renamed or removed.
      SOURCE_REFERENCES = {
        "application_form" => {
          files: %w[
            app/models/strata/application_form.rb
            app/lib/strata/attributes.rb
            app/lib/strata/attributes/address_attribute.rb
            app/lib/strata/attributes/name_attribute.rb
            app/lib/strata/attributes/memorable_date_attribute.rb
            app/models/concerns/strata/determinable.rb
            app/views/strata/application_forms/index.html.erb
            app/views/strata/application_forms/show.html.erb
            app/views/strata/shared/_form_buttons.html.erb
            app/views/strata/shared/_exit_link.html.erb
            app/views/strata/shared/_breadcrumbs.html.erb
            lib/generators/strata/application_form_views/templates/layout.html.erb.tt
            lib/generators/strata/application_form_views/templates/edit_page.html.erb.tt
            docs/intake-application-forms.md
            docs/multi-page-form-flows.md
          ]
        }
      }.freeze

      AGENT_DIRS = {
        "claude" => ".claude/rules",
        "cursor" => ".cursor/rules",
        "copilot" => ".copilot/rules"
      }.freeze

      DEFAULT_RULES_DIR = ".agents/rules"

      desc "Generates path-scoped agent rules for Strata SDK features"

      class_option :agent, type: :string,
        desc: "Target agent (claude, cursor, copilot). Default: writes to .agents/rules/"
      class_option :force, type: :boolean, default: true,
        desc: "Overwrite existing rule files"

      def validate_feature_name
        return if name == "all"

        unless SUPPORTED_FEATURES.include?(name.underscore)
          raise Thor::Error, "Unknown feature '#{name}'. Supported: #{SUPPORTED_FEATURES.join(', ')}, all"
        end
      end

      def generate_rules
        features = name == "all" ? SUPPORTED_FEATURES : [ name.underscore ]
        features.each do |feature|
          # Root rule file
          render_erb_template(
            "#{feature}.md.erb",
            File.join(output_dir, "strata-sdk", "strata-#{feature.dasherize}.md")
          )

          # Sub-rule files from feature subdirectory
          sub_template_dir = File.join(self.class.source_root, feature)
          next unless File.directory?(sub_template_dir)

          Dir.glob("#{sub_template_dir}/*.md.erb").sort.each do |sub_template_path|
            sub_name = File.basename(sub_template_path, ".md.erb")
            render_erb_template(
              File.join(feature, "#{sub_name}.md.erb"),
              File.join(output_dir, "strata-sdk", "strata-#{feature.dasherize}", "#{sub_name}.md")
            )
          end
        end
      end

      private

      # Walk up from destination_root to find the git root (.git directory).
      # Falls back to destination_root if no .git is found (e.g., in tests).
      def git_root
        dir = Pathname.new(destination_root).expand_path
        loop do
          return dir if (dir + ".git").exist?
          parent = dir.parent
          return Pathname.new(destination_root).expand_path if parent == dir
          dir = parent
        end
      end

      def output_dir
        agent_subdir = AGENT_DIRS.fetch(options[:agent]&.downcase, DEFAULT_RULES_DIR)
        git_root.join(agent_subdir).to_s
      end

      def render_erb_template(template_relative_path, destination)
        source_path = File.join(self.class.source_root, template_relative_path)
        erb_content = File.read(source_path, encoding: "UTF-8")
        rendered = ERB.new(erb_content, trim_mode: "-").result(binding)
        create_file destination, rendered
      end
    end
  end
end
