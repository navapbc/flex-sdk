TestBusinessProcess = Flex::BusinessProcess.define(:test, TestCase) do |bp|
  bp.step('foo', Flex::UserTask.new("Foo", UserTaskCreationService))
  bp.start('foo')
  bp.transition('foo', 'case_closed', 'end')
end
