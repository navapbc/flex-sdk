# frozen_string_literal: true

# Lookbook preview for the TaskListComponent.
class SampleTaskListPreview < Lookbook::Preview
  def default
    flow = SampleFlow.new(FactoryBot.build_stubbed(
      :sample_application_form,
      applicant_name_first: "Name",
      leave_type: "medical"
    ))
    render Strata::Flows::TaskListComponent.new(
      flow:
    )
  end

  def with_step_label
    flow = SampleFlow.new(FactoryBot.build_stubbed(
      :sample_application_form,
      applicant_name_first: "Name",
      leave_type: "medical"
    ))
    render Strata::Flows::TaskListComponent.new(
      flow:,
      show_step_label: true
    )
  end

  # @label No tasks completed
  # @note Only the first task (Personal Information) is startable. Employment Details and Leave Details show "Cannot start yet" because their dependencies are not met.
  def depends_on_no_tasks_completed
    flow = SampleFlow.new(FactoryBot.build_stubbed(:sample_application_form))
    render Strata::Flows::TaskListComponent.new(flow:, show_step_label: true)
  end

  # @label First page empty, later page has data
  # @note Personal Information has data on the second page (Date of Birth) but the first page (Name) is empty. Shows "Continue" because some sub-page has data, and routes to the first incomplete page.
  def first_page_empty_later_page_has_data
    flow = SampleFlow.new(FactoryBot.build_stubbed(
      :sample_application_form,
      date_of_birth: Date.new(1990, 5, 15)
    ))
    render Strata::Flows::TaskListComponent.new(flow:, show_step_label: true)
  end

  # @label First task completed
  # @note Personal Information is completed, unlocking Employment Details. Leave Details still shows "Cannot start yet" because it depends on Employment Details.
  def depends_on_first_task_completed
    flow = SampleFlow.new(FactoryBot.build_stubbed(
      :sample_application_form,
      applicant_name_first: "Jane",
      date_of_birth: Date.new(1990, 5, 15)
    ))
    render Strata::Flows::TaskListComponent.new(flow:, show_step_label: true)
  end

  # @label Two tasks completed
  # @note Personal Information and Employment Details are completed, unlocking Leave Details.
  def depends_on_two_tasks_completed
    flow = SampleFlow.new(FactoryBot.build_stubbed(
      :sample_application_form,
      applicant_name_first: "Jane",
      date_of_birth: Date.new(1990, 5, 15),
      employer_name: "Acme Corp"
    ))
    render Strata::Flows::TaskListComponent.new(flow:, show_step_label: true)
  end

  # @label All tasks completed
  # @note All tasks are completed and show the "Completed" status with edit links.
  def depends_on_all_tasks_completed
    flow = SampleFlow.new(FactoryBot.build_stubbed(:sample_application_form, :submittable))
    render Strata::Flows::TaskListComponent.new(flow:, show_step_label: true)
  end

  def diagram
    render template: "strata/previews/_business_process", locals: { business_process: SampleFlow }
  end
end
