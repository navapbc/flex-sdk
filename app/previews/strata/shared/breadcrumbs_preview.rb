module Strata
  module Shared
    # BreadcrumbsPreview provides a preview example for the breadcrumbs component.
    # It demonstrates the standard breadcrumb navigation used throughout the application.
    #
    # This class is used with Lookbook to generate UI component previews
    # for the breadcrumbs component used in navigation.
    #
    # @example Viewing the breadcrumbs preview
    #   # In Lookbook UI
    #   # Navigate to Flex > BreadcrumbsPreview > default
    #
    class BreadcrumbsPreview < Lookbook::Preview
      layout "component_preview"

      def default
        render template: "strata/shared/_breadcrumbs", locals: {
          breadcrumbs: [
            { text: "Home", link: "/" },
            { text: "Cases", link: "/cases" },
            { text: "Case 12345" }
          ]
        }
      end
    end
  end
end
