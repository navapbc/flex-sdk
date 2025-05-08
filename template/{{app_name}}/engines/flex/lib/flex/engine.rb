module Flex
  class Engine < ::Rails::Engine
    isolate_namespace Flex

    initializer "flex.autoload", before: :set_autoload_paths do |app|
      config.autoload_paths += %W[#{config.root}/lib]
      config.eager_load_paths += %W[#{config.root}/lib]
    end
  end
end
