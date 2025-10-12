# frozen_string_literal: true

module Strata
  # Base controller for all staff-related functionality.
  # Sets the layout to the strata/staff layout.
  #
  # To customize the header in a subclass of StaffController, override the following methods:
  # - case_classes: Specify which case types to display as links in the header.
  # - tasks_links: Customize or add additional links related to tasks.
  # - header_links: Completely override this method to fully control the header links if needed.
  #
  # Example:
  #   def case_classes
  #     [ PassportCase, VisaCase ]
  #   end
  #
  #   def tasks_links
  #     super + [{ name: "My Custom Task", path: custom_task_path }]
  #   end
  #
  #   def header_links
  #     # Fully customize header links if default combining isn't sufficient
  #     [ { name: "Home", path: home_path } ] + super
  #   end
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
      (cases_links + tasks_links).compact
    end

    def tasks_links
      [ { name: t("strata.staff.header.tasks"), path: main_app.tasks_path } ]
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
