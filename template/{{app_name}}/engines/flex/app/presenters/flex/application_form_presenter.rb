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
        status: application_form.status
      }
    end

    def show
      {
        title: t_scoped("show.title"),
        back_link_text:  t_scoped("show.back"),
        index_path: view_context.polymorphic_path(application_form.class),
        created_at:  created_at,
        current_status: application_form.status,
        next_step: t_scoped("show.next_step.status.#{application_form.status}"),
        submitted_on_text: t_scoped("show.submitted_on")
      }
    end

    private

    def created_at
      application_form.created_at.strftime("%B %d, %Y at %I:%M %p")
    end
  end
end
