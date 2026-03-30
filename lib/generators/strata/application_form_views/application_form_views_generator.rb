# frozen_string_literal: true

require "rails/generators"

module Strata
  module Generators
    # Generator for creating ApplicationFormFlow view files.
    #
    # For each question_page in the given flow, creates an edit_<page_name>.html.erb
    # view file with appropriate form fields based on the ApplicationForm model's attributes.
    #
    # @example
    #   rails generate strata:application_form_views LeaveApplicationFlow LeaveApplicationForm
    class ApplicationFormViewsGenerator < Rails::Generators::Base
      argument :flow_name, type: :string, desc: "The ApplicationFormFlow class name"
      argument :form_name, type: :string, desc: "The ApplicationForm class name"

      STRATA_TYPE_MAP = {
        date_from_hash: :memorable_date,
        money: :money,
        tax_id: :tax_id,
        us_date: :us_date
      }.freeze

      def create_view_files
        flow_class = flow_name.constantize
        form_class = form_name.constantize

        @locale_data = {}

        flow_class.tasks.each do |task|
          task.pages.each do |page|
            create_view_for_page(page, form_class)
          end
        end

        create_layout_file
        create_or_update_locale_file
      end

      private

      def layout_name
        base = form_name.underscore
        base.end_with?("_form") ? base : "#{base}_form"
      end

      def views_directory
        "app/views/#{form_name.underscore.pluralize}"
      end

      def create_layout_file
        form_scope = form_name.underscore.pluralize
        @locale_data["actions"] = { "exit" => "Exit" }

        content = <<~ERB
          <%= content_for :content do %>
            <%= render partial: "strata/shared/exit_link", locals: {
              exit_path: @flow.start_path,
              exit_text: t("#{form_scope}.actions.exit")
            } %>
            <%= render partial: "strata/shared/step_indicator", locals: {
              steps: @flow_task.pages.map(&:name),
              current_step: @flow_task.current_page.name
            } %>
            <%= yield %>
          <% end %>

          <%= render template: "layouts/application" %>
        ERB

        create_file "app/views/layouts/#{layout_name}.html.erb", content
      end

      def create_view_for_page(page, form_class)
        fields = resolve_fields(page.fields, form_class)
        content = build_view_content(page.name, fields)
        create_file "#{views_directory}/edit_#{page.name}.html.erb", content
        collect_locale_data(page.name, fields)
      end

      def resolve_fields(raw_fields, form_class)
        attachment_names = form_class.reflect_on_all_attachments.map { |a| a.name.to_s }

        raw_fields.filter_map do |field|
          if field.is_a?(Hash)
            resolve_hash_field(field, form_class, attachment_names)
          else
            resolve_simple_field(field, form_class, attachment_names)
          end
        end
      end

      def resolve_hash_field(field_hash, form_class, attachment_names)
        field_name = field_hash.keys.first.to_s

        return nil if skip_field?(field_name, form_class, attachment_names)

        helper = detect_field_helper(field_name.to_sym, form_class)
        return nil unless helper

        helper
      end

      def resolve_simple_field(field, form_class, attachment_names)
        field_name = field.to_s

        return nil if skip_field?(field_name, form_class, attachment_names)

        helper = detect_field_helper(field, form_class)
        return nil unless helper

        helper
      end

      def skip_field?(field_name, form_class, attachment_names)
        return true if field_name.end_with?("_attributes")
        return true if attachment_names.include?(field_name)
        return true unless field_exists_on_form?(field_name, form_class)

        false
      end

      def field_exists_on_form?(field_name, form_class)
        form_class.attribute_types.key?(field_name) ||
          form_class.method_defined?(field_name.to_sym) ||
          form_class.column_names.include?(field_name)
      end

      def detect_field_helper(field, form_class)
        field_name = field.to_s

        # Check for single-column strata attributes
        strata_helper = detect_strata_type(field_name, form_class)
        return strata_helper if strata_helper

        # Check for multi-column strata attributes (name, address)
        multi_column_helper = detect_multi_column_strata_type(field_name, form_class)
        return multi_column_helper if multi_column_helper

        # Check for enums
        return build_enum_helper(field_name, form_class) if form_class.defined_enums.key?(field_name)

        # Check for booleans
        return { helper: :yes_no, field: field_name.to_sym } if boolean_field?(field_name, form_class)

        # Fall back to standard column type detection
        detect_column_type_helper(field_name, form_class)
      end

      def detect_strata_type(field_name, form_class)
        attr_type = form_class.attribute_types[field_name]
        return nil unless attr_type

        strata_type = STRATA_TYPE_MAP[attr_type.type]
        return nil unless strata_type

        case strata_type
        when :memorable_date
          { helper: :memorable_date, field: field_name.to_sym }
        when :money
          { helper: :money_field, field: field_name.to_sym }
        when :tax_id
          { helper: :tax_id_field, field: field_name.to_sym }
        when :us_date
          { helper: :date_picker, field: field_name.to_sym }
        end
      end

      def detect_multi_column_strata_type(field_name, form_class)
        return nil unless form_class.method_defined?(field_name.to_sym)

        if form_class.attribute_types.key?("#{field_name}_first")
          { helper: :name, field: field_name.to_sym }
        elsif form_class.attribute_types.key?("#{field_name}_street_line_1")
          { helper: :address_fields, field: field_name.to_sym }
        end
      end

      def boolean_field?(field_name, form_class)
        attr_type = form_class.attribute_types[field_name]
        return attr_type.is_a?(ActiveModel::Type::Boolean) if attr_type

        column = form_class.columns_hash[field_name]
        column&.type == :boolean
      end

      def build_enum_helper(field_name, form_class)
        values = form_class.defined_enums[field_name].keys
        { helper: :enum, field: field_name.to_sym, values: values }
      end

      def detect_column_type_helper(field_name, form_class)
        column = form_class.columns_hash[field_name]
        return nil unless column

        case column.type
        when :date, :datetime
          { helper: :date_picker, field: field_name.to_sym }
        when :text
          { helper: :text_area, field: field_name.to_sym }
        when :integer, :decimal, :float
          { helper: :text_field, field: field_name.to_sym, options: { inputmode: "numeric" } }
        else
          { helper: :text_field, field: field_name.to_sym }
        end
      end

      def build_view_content(page_name, fields)
        lines = []
        lines << "<%= strata_form_with model: flow_record, url: @flow_task.update_path, method: :patch do |f| %>"
        lines << "  <h2 class=\"usa-form-heading\"><%= t(\".#{page_name}_title\") %></h2>"

        fields.each do |field_info|
          lines << render_field(field_info)
        end

        lines << ""
        lines << '  <%= render partial: "form_buttons", locals: { back_path: @flow_task.prev_path || @flow.start_path, f: f } %>'
        lines << "<% end %>"
        lines.join("\n") + "\n"
      end

      def render_field(field_info)
        case field_info[:helper]
        when :enum
          render_enum_field(field_info)
        when :text_field
          if field_info[:options]
            opts = field_info[:options].map { |k, v| "#{k}: \"#{v}\"" }.join(", ")
            "  <%= f.text_field :#{field_info[:field]}, #{opts} %>"
          else
            "  <%= f.text_field :#{field_info[:field]} %>"
          end
        else
          "  <%= f.#{field_info[:helper]} :#{field_info[:field]} %>"
        end
      end

      def render_enum_field(field_info)
        lines = []
        lines << "  <%= f.fieldset t(\".#{field_info[:field]}_legend\") do %>"
        field_info[:values].each do |value|
          lines << "    <%= f.radio_button :#{field_info[:field]}, \"#{value}\", label: t(\".#{field_info[:field]}_#{value}\") %>"
        end
        lines << "  <% end %>"
        lines.join("\n")
      end

      def collect_locale_data(page_name, fields)
        page_translations = {}
        page_translations["#{page_name}_title"] = page_name.to_s.humanize

        fields.each do |field_info|
          next unless field_info[:helper] == :enum

          page_translations["#{field_info[:field]}_legend"] = field_info[:field].to_s.humanize
          field_info[:values].each do |value|
            page_translations["#{field_info[:field]}_#{value}"] = value.humanize
          end
        end

        @locale_data["edit_#{page_name}"] = page_translations
      end

      def locale_file_path
        "config/locales/#{form_name.underscore.pluralize}/en.yml"
      end

      def create_or_update_locale_file
        new_translations = { "en" => { form_name.underscore.pluralize => @locale_data } }
        full_path = File.join(destination_root, locale_file_path)

        if File.exist?(full_path)
          existing = YAML.safe_load(File.read(full_path)) || {}
          merged = deep_merge(existing, new_translations)
          create_file locale_file_path, merged.to_yaml, force: true
        else
          create_file locale_file_path, new_translations.to_yaml
        end
      end

      def deep_merge(base, override)
        base.merge(override) do |_key, old_val, new_val|
          if old_val.is_a?(Hash) && new_val.is_a?(Hash)
            deep_merge(old_val, new_val)
          else
            new_val
          end
        end
      end
    end
  end
end
