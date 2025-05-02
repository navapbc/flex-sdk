module Flex
  class ApplicationFormsPresenter
    attr_reader :application_forms

    def initialize(application_forms, controller_path)
      @application_forms = application_forms
      @controller_path = controller_path.gsub('/', '.')
    end

    def index
      {
        title: title,
        intro: intro,
        new_button_text: new_button_text,
        in_progress_applications_heading: in_progress_applications_heading,
        application_forms: application_forms.map { |application_form| Flex::ApplicationFormPresenter.new(application_form).index }
      }
    end

    private

    def title
      I18n.t("#{@controller_path}.index.title")
    end

    def intro
      I18n.t("#{@controller_path}.index.intro")
    end

    def new_button_text
      I18n.t("#{@controller_path}.index.new_button")
    end

    def in_progress_applications_heading
      I18n.t("#{@controller_path}.index.in_progress_applications.heading")
    end
  end
end
