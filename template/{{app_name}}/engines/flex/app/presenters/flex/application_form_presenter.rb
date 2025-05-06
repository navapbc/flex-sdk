module Flex
  class ApplicationFormPresenter
    def initialize(view_context, application_form)
      @view_context = view_context
      @application_form = application_form
      @i18n_path = view_context.controller_path.gsub("/", ".")
    end

    def index
      {
        created_at: created_at,
        path: @view_context.polymorphic_path(@application_form),
        status: status
      }
    end

    def show
      {
        title: title,
        back_link_text: back_link_text,
        index_path: index_path,
        created_at: created_at,
        current_status: current_status,
        more_info_needed_heading: more_info_needed_heading,
        more_info_needed_item: more_info_needed_item,
        next_step: next_step,
        submitted_on_text: submitted_on_text,
        status: status
      }

    private

    def title
      I18n.t("#{@i18n_path}.title")
    end

    def back_link_text
      I18n.t("#{@i18n_path}.back")
    end

    def index_path
      @view_context.polymorphic_path(@application_form.class)
    end

    def created_at
      @application_form.created_at.strftime("%B %d, %Y at %I:%M %p")
    end
    
    def current_status
      @application_form.status
    end
    
    def more_info_needed_heading
      I18n.t("#{@i18n_path}.more_info_needed_heading")
    end
    
    def more_info_needed_item
      I18n.t("#{@i18n_path}.more_info_needed_item")
    end
    
    def next_step
      I18n.t("#{@i18n_path}.next_step.status.#{@application_form.status}")
    end

    def submitted_on_text
      I18n.t("#{@i18n_path}.submitted_on")
    end

    def status
      I18n.t("flex.application_forms.status.#{@application_form.status}")
    end
  end
end
