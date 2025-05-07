module Flex
  # Presenter for the application forms index view
  # Handles presenting a collection of subclasses of Flex::ApplicationForm
  #
  # @example
  #   presenter = Flex::ApplicationFormsPresenter.new(view_context, application_forms)
  #   render template: "flex/application_forms/index", locals: presenter.index
  class ApplicationFormsPresenter < Flex::Presenter
    attr_reader :application_forms

    # @param view_context [ActionView::Base] the view context
    # @param application_forms [Array<ApplicationForm>] collection of application forms to present
    def initialize(view_context, application_forms)
      super(view_context)
      @application_forms = application_forms
    end

    # Prepares data for the index view
    # @return [Hash] locals for the index template
    def index
      {
        title: t_scoped("index.title"),
        intro: t_scoped("index.intro"),
        new_button_text: t_scoped("index.new_button"),
        in_progress_applications_heading: t_scoped("index.in_progress_applications.heading"),
        application_forms: application_forms.map { |application_form| Flex::ApplicationFormPresenter.new(view_context, application_form).index }
      }
    end
  end
end
