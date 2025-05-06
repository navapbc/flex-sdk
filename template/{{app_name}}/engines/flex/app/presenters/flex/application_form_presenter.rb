module Flex
  class ApplicationFormPresenter
    def initialize(view_context, application_form)
      @view_context = view_context
      @application_form = application_form
    end

    def index
      {
        created_at: created_at,
        path: @view_context.polymorphic_path(@application_form),
        status: status
      }
    end

    private

    def created_at
      @application_form.created_at.strftime("%B %d, %Y at %I:%M %p")
    end

    def object
      @application_form
    end

    def status
      I18n.t("flex.application_forms.status.#{@application_form.status}")
    end
  end
end
