module Strata
  # Base controller for all staff-related functionality.
  # Sets the layout to the strata/staff layout
  class StaffController < ApplicationController
    layout "strata/staff"

    before_action :set_header_cases_links

    attr_reader :cases_links
    helper_method :cases_links

    def index
    end

    protected

    def case_classes
      []
    end

    def set_header_cases_links
      @cases_links = case_classes.map { |klass| cases_link_or_nil(klass) }.compact
    end

    private

    def cases_link_or_nil(klass)
      {
        name: klass.name.underscore.pluralize.titleize,
        path: main_app.polymorphic_path(klass)
      }
    rescue NoMethodError, ActionController::UrlGenerationError
      nil
    end
  end
end
