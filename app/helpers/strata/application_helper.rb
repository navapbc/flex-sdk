# frozen_string_literal: true

module Strata
  # ApplicationHelper provides view helpers for common tasks in Strata applications.
  # It includes the strata_form_with method.
  #
  # @see Strata::FormBuilder for more information about available form helpers
  #
  module ApplicationHelper
    STIMULUS_CDN_URL = "https://cdn.jsdelivr.net/npm/@hotwired/stimulus@3/dist/stimulus.min.js"

    def strata_form_with(model: false, scope: nil, url: nil, format: nil, **options, &block)
      options[:builder] = Strata::FormBuilder
      args = { scope: scope, url: url, format: format, **options }
      args[:model] = model if model
      form_with(**args, &block)
    end

    def strata_stimulus_tags
      controllers = strata_stimulus_controllers
      imports = { "@hotwired/stimulus" => STIMULUS_CDN_URL }

      controllers.each do |_identifier, asset_module|
        imports[asset_module] = asset_path("#{asset_module}.js")
      end

      import_lines = controllers.map { |_, mod| "import #{js_const(mod)} from \"#{mod}\"" }
      register_lines = controllers.map { |id, mod| "application.register(\"#{id}\", #{js_const(mod)})" }

      importmap_json = { imports: imports }.to_json

      safe_join([
        tag.script(raw(importmap_json), type: "importmap"),
        "\n",
        tag.script(
          raw([
            'import { Application } from "@hotwired/stimulus"',
            *import_lines,
            "const application = Application.start()",
            *register_lines
          ].join("\n")),
          type: "module"
        )
      ])
    end

    private

    def strata_stimulus_controllers
      components_path = Strata::Engine.root.join("app/components")
      Dir[components_path.join("**/*_component_controller.js")].map do |path|
        relative = Pathname.new(path).relative_path_from(components_path).to_s.delete_suffix(".js")
        identifier = stimulus_identifier_from(relative)
        [ identifier, relative ]
      end
    end

    def stimulus_identifier_from(relative_path)
      # "strata/conditional_field_component_controller" => "strata--conditional-field"
      # Stimulus uses "--" for namespace separators (directories) and "-" for underscores
      relative_path
        .delete_suffix("_controller")
        .delete_suffix("_component")
        .gsub("/", "--")
        .gsub("_", "-")
    end

    def js_const(module_path)
      module_path.split("/").last.gsub(/(^|_)(.)/) { $2.upcase }
    end
  end
end
