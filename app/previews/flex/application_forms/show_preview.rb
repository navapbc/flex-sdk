module Flex
  module ApplicationForms
    class ShowPreview < Lookbook::Preview
      def in_progress
        render template: "flex/application_forms/show", locals: {
          title: "My Application",
          back_link_text: "Back to Applications",
          index_path: "/applications",
          created_at: "2024-01-15",
          current_status: :in_progress,
          next_step: "Please complete all required fields.",
          submitted_on_text: "Started on"
        }
      end

      def submitted
        render template: "flex/application_forms/show", locals: {
          title: "My Application",
          back_link_text: "Back to Applications",
          index_path: "/applications",
          created_at: "2024-01-10",
          current_status: :submitted,
          next_step: "Your application is under review.",
          submitted_on_text: "Submitted on"
        }
      end
    end
  end
end
