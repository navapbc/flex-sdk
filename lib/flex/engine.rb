module Flex
  class Engine < ::Rails::Engine
    isolate_namespace Flex

    initializer 'flex.helpers' do
      ActiveSupport.on_load :action_controller do
        helper Flex::ApplicationHelper
      end
    end
  end
end
