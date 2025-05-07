module Flex
  class Engine < ::Rails::Engine
    isolate_namespace Flex

    config.autoload_paths += %W[#{config.root}/lib]
    config.eager_load_paths += %W[#{config.root}/lib]
  end
end
