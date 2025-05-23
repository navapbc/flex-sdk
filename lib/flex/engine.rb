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

    config.after_initialize do
      Rails.autoloaders.main.on_unload("Flex::EventManager") do |klass|
        klass.unsubscribe_all
      end
    end
  end
end
