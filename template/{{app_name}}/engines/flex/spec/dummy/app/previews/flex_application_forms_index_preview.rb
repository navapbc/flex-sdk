class FlexApplicationFormsIndexPreview < Lookbook::Preview
  def empty
    render template: "flex/application_forms/index", locals: {
      title: "My Applications",
      intro: "Start a new application or continue an existing one.",
      new_button_text: "Start New Application",
      in_progress_applications_heading: "Your Applications",
      application_forms: []
    }
  end

  def with_applications
    render template: "flex/application_forms/index", locals: {
      title: "My Applications",
      intro: "Start a new application or continue an existing one.",
      new_button_text: "Start New Application",
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
