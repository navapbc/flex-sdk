module Flex
  class ApplicationFormsPresenter
    attr_reader :application_forms

    def initialize(view_context, application_forms)
      @view_context = view_context
      @application_forms = application_forms
      @i18n_path = view_context.controller_path.gsub("/", ".")
    end

    def index
      {
        title: I18n.t("#{@i18n_path}.index.title"),
        intro: I18n.t("#{@i18n_path}.index.intro"),
        new_button_text: I18n.t("#{@i18n_path}.index.new_button"),
        in_progress_applications_heading: I18n.t("#{@i18n_path}.index.in_progress_applications.heading"),
        application_forms: application_forms.map { |application_form| Flex::ApplicationFormPresenter.new(@view_context, application_form).index }
      }
    end
  end
end
