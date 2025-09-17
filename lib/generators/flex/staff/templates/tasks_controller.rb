class TasksController < Flex::TasksController
  before_action :set_case, only: %i[ show update ]
  before_action :set_application_form, only: %i[ show update ]

  private

  def set_case
    # all tasks need the following association
    # belongs_to :case, class_name: "ExampleCase"
    @case = @task.case
  end

  def set_application_form
    # all cases need the following association
    # has_one :application_form, foreign_key: :id, primary_key: :application_form_id, class_name: "ExampleApplicationForm"
    @application_form = @case.application_form
  end
end
