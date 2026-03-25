# frozen_string_literal: true

# Lookbook preview for the TaskListComponent.
class PaidLeaveTaskListPreview < Lookbook::Preview
  def default
    flow = PaidLeaveFlow.new(FactoryBot.build_stubbed(
      :paid_leave_application_form,
      applicant_name_first: "Name",
      leave_type: "medical"
    ))
    render Strata::Flows::TaskListComponent.new(
      flow:
    )
  end

  def with_step_label
    flow = PaidLeaveFlow.new(FactoryBot.build_stubbed(
      :paid_leave_application_form,
      applicant_name_first: "Name",
      leave_type: "medical"
    ))
    render Strata::Flows::TaskListComponent.new(
      flow:,
      show_step_label: true
    )
  end

  # @label No tasks completed
  # @notes Only the first task (Personal Information) is startable. Employment Details and Leave Details show "Cannot start yet" because their dependencies are not met.
  def depends_on_no_tasks_completed
    flow = PaidLeaveFlow.new(FactoryBot.build_stubbed(:paid_leave_application_form))
    render Strata::Flows::TaskListComponent.new(flow:, show_step_label: true)
  end

  # @label First task completed
  # @notes Personal Information is completed, unlocking Employment Details. Leave Details still shows "Cannot start yet" because it depends on Employment Details.
  def depends_on_first_task_completed
    flow = PaidLeaveFlow.new(FactoryBot.build_stubbed(
      :paid_leave_application_form,
      applicant_name_first: "Jane",
      date_of_birth: Date.new(1990, 5, 15)
    ))
    render Strata::Flows::TaskListComponent.new(flow:, show_step_label: true)
  end

  # @label Two tasks completed
  # @notes Personal Information and Employment Details are completed, unlocking Leave Details.
  def depends_on_two_tasks_completed
    flow = PaidLeaveFlow.new(FactoryBot.build_stubbed(
      :paid_leave_application_form,
      applicant_name_first: "Jane",
      date_of_birth: Date.new(1990, 5, 15),
      employer_name: "Acme Corp"
    ))
    render Strata::Flows::TaskListComponent.new(flow:, show_step_label: true)
  end

  # @label All tasks completed
  # @notes All tasks are completed and show the "Completed" status with edit links.
  def depends_on_all_tasks_completed
    flow = PaidLeaveFlow.new(FactoryBot.build_stubbed(:paid_leave_application_form, :submittable))
    render Strata::Flows::TaskListComponent.new(flow:, show_step_label: true)
  end

  def diagram
    render template: "strata/previews/_business_process", locals: { business_process: PaidLeaveFlow }
  end
end
