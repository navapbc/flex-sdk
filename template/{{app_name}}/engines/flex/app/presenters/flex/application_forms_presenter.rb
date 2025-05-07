module Flex
  class ApplicationFormsPresenter < Flex::Presenter
    attr_reader :application_forms

    def initialize(view_context, application_forms)
      super(view_context)
      @application_forms = application_forms
    end

    def index
      {
        title: t("index.title"),
        intro: t("index.intro"),
        new_button_text: t("index.new_button"),
        in_progress_applications_heading: t("index.in_progress_applications.heading"),
        application_forms: application_forms.map { |application_form| Flex::ApplicationFormPresenter.new(view_context, application_form).index }
      }
    end
  end
end
