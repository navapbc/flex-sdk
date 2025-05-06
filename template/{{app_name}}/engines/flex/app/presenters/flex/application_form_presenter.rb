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
        title: I18n.t("#{@i18n_path}.show.title"),
        back_link_text:  I18n.t("#{@i18n_path}.show.back"),
        index_path: @view_context.polymorphic_path(@application_form.class),
        created_at:  created_at,
        current_status: @application_form.status,
        next_step: I18n.t("#{@i18n_path}.show.next_step.status.#{@application_form.status}"),
        submitted_on_text: I18n.t("#{@i18n_path}.show.submitted_on"),
        status: status
      }
    end

    private 

    def created_at
      @application_form.created_at.strftime("%B %d, %Y at %I:%M %p")
    end

    def status
      I18n.t("flex.application_forms.status.#{@application_form.status}")
    end
  end
end
