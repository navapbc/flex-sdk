require "rails"
require "flex_sdk/engine"

module FlexSdk
  class Engine < ::Rails::Engine
    isolate_namespace FlexSdk

    initializer :append_migrations do |app|
      unless app.root.to_s.match? root.to_s
        app.config.paths["db/migrate"].concat(config.paths["db/migrate"].expanded)
      end
    end
  end
end
