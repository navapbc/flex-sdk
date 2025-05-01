module Flex
  class ApplicationFormsPresenter
    attr_reader :application_forms

    def initialize(application_forms, i18n_path)
      @application_forms = application_forms
      @i18n_path = i18n_path
    end

    def title
      I18n.t("#{@i18n_path}.title")
    end

    def intro
      I18n.t("#{@i18n_path}.intro")
    end

    def new_button_text
      I18n.t("#{@i18n_path}.new_button")
    end
  end
end
