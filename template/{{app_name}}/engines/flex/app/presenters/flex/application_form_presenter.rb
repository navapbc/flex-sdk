module Flex
  # Presenter for single application form views
  # Handles presenting individual instances of a Flex::ApplicationForm or subclass
  # of Flex::ApplicationForm
  #
  # @example
  #   presenter = Flex::ApplicationFormPresenter.new(view_context, application_form)
  #   render template: "flex/application_forms/show", locals: presenter.show
  class ApplicationFormPresenter < Flex::Presenter
    attr_reader :application_form

    # @param view_context [ActionView::Base] the view context
    # @param application_form [ApplicationForm] the application form to present
    def initialize(view_context, application_form)
      super(view_context)
      @application_form = application_form
    end

    # Prepares data for index view list items
    # @return [Hash] locals for the index list item
    def index
      {
        created_at: created_at,
        path: view_context.polymorphic_path(application_form),
        status: application_form.status
      }
    end

    # Prepares data for the show view
    # @return [Hash] locals for the show template
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
