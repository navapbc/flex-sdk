TestBusinessProcess = Flex::BusinessProcess.define(:test, TestCase) do |bp|
  # Define steps
  bp.step('staff_task',
    Flex::StaffTask.new("staff_task", StaffTaskCreationService))

  bp.step('system_process',
    Flex::SystemProcess.new("system_process", ->(kase) {
      Flex::EventManager.publish("event2", { case_id: kase.id })
    }))

  bp.step('staff_task_2',
    Flex::StaffTask.new("staff_task_2", StaffTaskCreationService))

  bp.step('applicant_task',
    Flex::ApplicantTask.new("Submit Required Documents"))

  bp.step('third_party_task',
    Flex::ThirdPartyTask.new("Review Employee Leave Application"))

  bp.step('system_process_2',
    Flex::SystemProcess.new("system_process_2", ->(kase) {
      Flex::EventManager.publish("event4", { case_id: kase.id })
    }))

  # Define start step
  bp.start_on_application_form_created('staff_task')

  # Define transitions
  bp.transition('staff_task', 'event1', 'system_process')
  bp.transition('system_process', 'event2', 'staff_task_2')
  bp.transition('staff_task_2', 'event3', 'applicant_task')
  bp.transition('applicant_task', 'event5', 'third_party_task')
  bp.transition('third_party_task', 'event6', 'system_process_2')
  bp.transition('system_process_2', 'event4', 'end')
end
