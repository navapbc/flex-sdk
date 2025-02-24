require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TemplateApplicationRails
  class Application < Rails::Application
    # Internationalization
    I18n.available_locales = [ :"en", :"es-US" ]
    I18n.default_locale = :"en"
    I18n.enforce_available_locales = true

    # Support nested locale files
    config.i18n.load_path += Dir[Rails.root.join("config", "locales", "**", "*.{rb,yml}")]

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks generators])

    # Prevent the form_with helper from wrapping input and labels with separate
    # div elements when an error is present, since this breaks USWDS styling
    # and functionality.
    config.action_view.field_error_proc = Proc.new { |html_tag, instance|
      html_tag
    }

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.generators do |g|
      g.factory_bot suffix: "factory"
    end

    # Support UUID generation. This was a callout in the ActiveStorage guide
    # https://edgeguides.rubyonrails.org/active_storage_overview.html#setup
    Rails.application.config.generators { |g| g.orm :active_record, primary_key_type: :uuid }

    # Show a 403 Forbidden error page when Pundit raises a NotAuthorizedError
    config.action_dispatch.rescue_responses["Pundit::NotAuthorizedError"] = :forbidden
  end
end
