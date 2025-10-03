# frozen_string_literal: true

class TestBusinessProcess < Strata::BusinessProcess
  # Define steps
  staff_task('staff_task', PassportPhotoTask)
  system_process('system_process', ->(kase) {
    Strata::EventManager.publish("event2", { case_id: kase.id })
  })
  staff_task('staff_task_2', PassportVerifyInfoTask)
  applicant_task('applicant_task')
  third_party_task('third_party_task')
  system_process('system_process_2', ->(kase) {
    Strata::EventManager.publish("event6", { case_id: kase.id })
  })

  # Define start step
  start_on_application_form_created('staff_task')

  # Define transitions
  transition('staff_task', 'event1', 'system_process')
  transition('system_process', 'event2', 'staff_task_2')
  transition('staff_task_2', 'event3', 'applicant_task')
  transition('applicant_task', 'event4', 'third_party_task')
  transition('third_party_task', 'event5', 'system_process_2')
  transition('system_process_2', 'event6', 'end')
end
