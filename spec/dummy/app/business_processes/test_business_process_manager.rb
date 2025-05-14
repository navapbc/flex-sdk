class TestBusinessProcessManager
  include Singleton

  attr_reader :business_process

  private

  def initialize
    @business_process = create_business_process
  end

  def create_business_process
    business_process = Flex::BusinessProcess.new(
      name: 'Test Process',
      find_case_callback: ->(case_id) { TestCase.find(case_id) },
      description: 'Process for testing the business process manager'
    )
    business_process.define_steps(
      {
        "foo" => Flex::UserTask.new("Foo", UserTaskCreationService)
      }
    )
    business_process.define_transitions(
      {
        "foo" => {
          "case_closed" => 'end'
        }
      }
    )
    business_process.define_start('foo')

    business_process
  end
end
