class TasksController < Flex::TasksController
  before_action :set_case, only: %i[ show update ]
  before_action :set_application_form, only: %i[ show update ]

  private

  def set_case
    case_class = @task.case_type.constantize
    @case = case_class.find(@task.case_id)
  end

  def set_application_form
    # TODO: get application form from @case
  end
end
