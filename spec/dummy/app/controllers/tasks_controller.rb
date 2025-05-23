class TasksController < Flex::TasksController
  def task_class
    PassportTask
  end

  def show
    super
    kase = PassportCase.find(@task.case_id)
    @application_form = PassportApplicationForm.find(kase.application_form_id)
  end
end
