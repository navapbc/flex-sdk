module Flex
  module Staff
    class HeaderPreview < Lookbook::Preview
      layout "component_preview"

      Request = Struct.new(:path)

      def default
        # to model the current path
        request = Request.new("/passport_cases")

        # render template: "flex/previews/empty", locals: {
        render template: "flex/staff/_header", locals: {
          cases_links: [
            { name: "Passport Cases", path: "/passport_cases" },
          ],
          request: request
        }
      end
    end
  end
end
