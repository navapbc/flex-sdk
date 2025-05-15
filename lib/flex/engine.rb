module Flex
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

    initializer "flex.start_business_processes" do |app|
      config.to_prepare do
        Flex::BusinessProcess.start_listening_for_events
      end
    end
  end
end
