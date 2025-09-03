module Flex
  module Cases
    class ShowPreview < Lookbook::Preview
      def default
        render template: "flex/previews/cases/show", locals: {
          status: :open
        }
      end

      def closed
        render template: "flex/previews/cases/show", locals: {
          status: :closed
        }
      end
    end
  end
end
