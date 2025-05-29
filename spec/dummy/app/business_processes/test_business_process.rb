TestBusinessProcess = Flex::BusinessProcess.define(:test, TestCase) do |bp|
  # Define steps
  bp.staff_task('staff_task', PassportPhotoTask)
  bp.system_process('system_process', ->(kase) {
    Flex::EventManager.publish("event2", { case_id: kase.id })
  })
  bp.staff_task('staff_task_2', PassportVerifyInfoTask)
  bp.applicant_task('applicant_task')
  bp.third_party_task('third_party_task')
  bp.system_process('system_process_2', ->(kase) {
    Flex::EventManager.publish("event6", { case_id: kase.id })
  })

  # Define start step
  bp.start_on_application_form_created('staff_task')

  # Define transitions
  bp.transition('staff_task', 'event1', 'system_process')
  bp.transition('system_process', 'event2', 'staff_task_2')
  bp.transition('staff_task_2', 'event3', 'applicant_task')
  bp.transition('applicant_task', 'event4', 'third_party_task')
  bp.transition('third_party_task', 'event5', 'system_process_2')
  bp.transition('system_process_2', 'event6', 'end')
end
