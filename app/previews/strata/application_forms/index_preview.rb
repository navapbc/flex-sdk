module Strata
  module ApplicationForms
    # IndexPreview provides preview examples for the application forms index view.
    # It demonstrates different states of the application forms list page.
    #
    # This class is used with Lookbook to generate UI component previews
    # for the application forms index page.
    #
    # @example Viewing the empty state preview
    #   # In Lookbook UI
    #   # Navigate to ApplicationForms > IndexPreview > empty
    #
    class IndexPreview < Lookbook::Preview
      def empty
        render template: "strata/application_forms/index", locals: {
          title: "My Applications",
          intro: "Start a new application or continue an existing one.",
          new_button_text: "Start New Application",
          new_path: "new",
          in_progress_applications_heading: "Your Applications",
          application_forms: []
        }
      end

      def with_applications
        render template: "strata/application_forms/index", locals: {
          title: "My Applications",
          intro: "Start a new application or continue an existing one.",
          new_button_text: "Start New Application",
          new_path: "new",
          in_progress_applications_heading: "Your Applications",
          application_forms: [
            {
              created_at: "2024-01-15",
              path: "/applications/1",
              status: :in_progress
            },
            {
              created_at: "2024-01-10",
              path: "/applications/2",
              status: :submitted
            }
          ]
        }
      end
    end
  end
end
