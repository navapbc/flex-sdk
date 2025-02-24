# Not to be confused with a "benefits application" or "claim".
# This is the parent class for all other controllers in the application.
class ApplicationController < ActionController::Base
  include Pundit::Authorization

  around_action :switch_locale
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  # Set the active locale based on the URL
  # For example, if the URL starts with /es-US, the locale will be set to :es-US
  def switch_locale(&action)
    locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  # After a user signs in, Devise uses this method to determine where to route them
  def after_sign_in_path_for(resource)
    unless resource.is_a?(User)
      raise "Unexpected resource type"
    end

    if resource.mfa_preference.nil?
      return users_mfa_preference_path
    end

    if resource.employer?
      return dev_sandbox_path
    end

    users_account_path
  end
end
