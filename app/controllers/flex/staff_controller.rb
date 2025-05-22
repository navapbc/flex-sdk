module Flex
  # Base controller for all staff-related functionality.
  # Sets the layout to the flex/staff layout
  class StaffController < Flex::ApplicationController
    layout "flex/staff"

    before_action :set_header_cases_links

    attr_reader :cases_links
    helper_method :cases_links

    protected

    def set_header_cases_links
      case_classes = Flex::Case.descendants
      @cases_links = case_classes.map { |klass| cases_link_or_nil(klass) }.compact
    end

    private

    def cases_link_or_nil(klass)
      {
        name: klass.name.underscore.pluralize.titleize,
        path: main_app.polymorphic_path(klass)
      }
    rescue NoMethodError
      nil
    rescue ActionController::UrlGenerationError
      nil
    end
  end
end
