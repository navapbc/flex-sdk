module Flex
  # Engine is the Rails engine for the Flex SDK.
  # It provides configuration for integrating Flex components into a Rails application.
  #
  # The engine handles namespace isolation, helper loading, preview path configuration,
  # and event manager cleanup during code reloading.
  #
  class Engine < ::Rails::Engine
    isolate_namespace Flex

    initializer "flex.helpers" do
      ActiveSupport.on_load :action_controller do
        helper Flex::ApplicationHelper
      end
    end

    initializer "flex.previews" do |app|
      config.lookbook.preview_paths << Flex::Engine.root.join("app", "previews") if config.respond_to?(:lookbook)
    end

    initializer "flex.factory_bot", after: "factory_bot.set_factory_paths" do
      if defined?(FactoryBot)
        FactoryBot.definition_file_paths << File.expand_path("../../../spec/factories/flex", __FILE__)
      end
    end

    initializer "flex.inflections" do
      ActiveSupport::Inflector.inflections(:en) do |inflect|
        inflect.acronym "US"
      end
    end

    config.after_initialize do
      Rails.autoloaders.main.on_unload("Flex::EventManager") do |klass|
        klass.unsubscribe_all
      end
    end
  end
end
