module Strata
  module Staff
    # This preview class demonstrates the Staff Header component in isolation.
    # It provides a default preview with sample navigation links.
    #
    # @example Basic usage with passport cases navigation
    #   HeaderPreview.new.default
    #   # => Renders header with "Passport Cases" navigation link
    #
    class HeaderPreview < Lookbook::Preview
      layout "component_preview"

      # Mock version of the Request class
      Request = Struct.new(:path)

      def default
        # Mock the request object in order to simulate the current path
        request = Request.new("/passport_cases/closed")

        # render template: "flex/previews/empty", locals: {
        render template: "flex/staff/_header", locals: {
          cases_links: [
            { name: "Passport Cases", path: "/staff/passport_cases" }
          ],
          request: request
        }
      end
    end
  end
end
