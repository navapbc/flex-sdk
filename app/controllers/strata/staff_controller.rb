# frozen_string_literal: true

module Strata
  # Base controller for all staff-related functionality.
  # Sets the layout to the strata/staff layout
  class StaffController < ApplicationController
    layout "strata/staff"

    helper_method :header_links

    def index
    end

    protected

    def case_classes
      []
    end

    def cases_links
      case_classes.map { |klass| cases_link_or_nil(klass) }.compact
    end

    def header_links
      (cases_links + [tasks_link]).compact
    end

    def tasks_link
      { name: t("strata.staff.header.tasks"), path: main_app.tasks_path }
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
