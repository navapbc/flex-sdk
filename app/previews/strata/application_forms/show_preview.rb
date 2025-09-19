module Strata
  module ApplicationForms
    # ShowPreview provides preview examples for the application form show view.
    # It demonstrates different states of the application form detail page.
    #
    # This class is used with Lookbook to generate UI component previews
    # for the application form detail page.
    #
    # @example Viewing the in-progress state preview
    #   # In Lookbook UI
    #   # Navigate to ApplicationForms > ShowPreview > in_progress
    #
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
