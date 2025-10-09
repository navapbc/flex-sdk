# frozen_string_literal: true

module USA
  # Engine is the Rails engine for USA (USWDS) components.
  # It provides configuration for integrating USA components into a Rails application.
  #
  class Engine < ::Rails::Engine
    isolate_namespace USA

    initializer "usa.previews" do |app|
      config.lookbook.preview_paths << USA::Engine.root.join("app", "previews") if config.respond_to?(:lookbook)
    end

    initializer "usa.inflections" do
      ActiveSupport::Inflector.inflections(:en) do |inflect|
        inflect.acronym "USA"
      end
    end
  end
end
