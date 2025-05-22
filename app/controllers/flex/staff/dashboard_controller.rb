module Flex
  module Staff
    # Controller for the staff dashboard at /staff.
    class DashboardController < Flex::StaffController
      def index
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
end
