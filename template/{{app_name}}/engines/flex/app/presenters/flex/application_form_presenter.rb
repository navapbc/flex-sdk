module Flex
  class ApplicationFormPresenter
    attr_reader :application_form

    def initialize(application_form, i18n_path)
      @application_form = application_form
      @i18n_path = i18n_path
    end

    def title
      I18n.t("#{@i18n_path}.title")
    end

    def back_link_text
      I18n.t("#{@i18n_path}.back")
    end

    def index_path
      Rails.application.routes.url_helpers.send("#{@application_form.class.name.underscore.pluralize}_path")
    end

    def next_step
      I18n.t("#{@i18n_path}.next_step.status.#{@application_form.status}")
    end

    def more_info_needed_heading
      I18n.t("#{@i18n_path}.more_info_needed_heading")
    end

    def more_info_needed_item
      I18n.t("#{@i18n_path}.more_info_needed_item")
    end

    def submitted_on_text
      I18n.t("#{@i18n_path}.submitted_on")
    end

    def created_at
      @application_form.created_at
    end

    def current_status
      @application_form.status
    end
  end
end
