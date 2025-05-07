module Flex
  class ApplicationFormPresenter < Flex::Presenter
    attr_reader :application_form

    def initialize(view_context, application_form)
      super(view_context)
      @application_form = application_form
    end

    def index
      {
        created_at: created_at,
        path: view_context.polymorphic_path(application_form),
        status: status
      }
    end

    def show
      {
        title: t("show.title"),
        back_link_text:  t("show.back"),
        index_path: view_context.polymorphic_path(application_form.class),
        created_at:  created_at,
        current_status: application_form.status,
        next_step: t("show.next_step.status.#{application_form.status}"),
        submitted_on_text: t("show.submitted_on"),
        status: status
      }
    end

    private

    def created_at
      application_form.created_at.strftime("%B %d, %Y at %I:%M %p")
    end

    def status
      I18n.t("flex.application_forms.status.#{application_form.status}")
    end
  end
end
