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

    initializer 'flex.load_business_processes' do
      # Load files that register BusinessProcess instances
      Dir[root.join('app/business_processes/**/*.rb')].each do |file|
        require_dependency file
      end
    end
  end
end
