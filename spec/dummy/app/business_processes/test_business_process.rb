TestBusinessProcess = Flex::BusinessProcess.define(:test, TestCase) do |bp|
  # Define steps
  bp.step('user_task',
    Flex::UserTask.new("user_task", UserTaskCreationService))

  bp.step('system_process',
    Flex::SystemProcess.new("system_process", ->(kase) {
      Flex::EventManager.publish("event2", { case_id: kase.id })
    }))

  bp.step('user_task_2',
    Flex::UserTask.new("user_task_2", UserTaskCreationService))

  bp.step('system_process_2',
    Flex::SystemProcess.new("system_process_2", ->(kase) {
      Flex::EventManager.publish("event4", { case_id: kase.id })
    }))

  # Define start step
  bp.start('user_task')

  # Define transitions
  bp.transition('user_task', 'event1', 'system_process')
  bp.transition('system_process', 'event2', 'user_task_2')
  bp.transition('user_task_2', 'event3', 'system_process_2')
  bp.transition('system_process_2', 'event4', 'end')
end
