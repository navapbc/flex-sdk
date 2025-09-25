class TasksController < Strata::TasksController
  def task_class
    PassportTask
  end

  def show
    super
    @case = PassportCase.find(@task.case_id)
    @application_form = PassportApplicationForm.find(@case.application_form_id)
  end

  protected

  def current_user
    User.all.sample
  end
end
