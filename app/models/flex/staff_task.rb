module Flex
  # StaffTask represents a task that requires human interaction.
  # It is used in business processes to create tasks that staff members
  # need to complete manually.
  #
  # StaffTask uses a task management service to create tasks when executed
  # within a business process.
  #
  # @example Defining a staff task in a business process
  #   bp.step('verify_documents',
  #     Flex::StaffTask.new("Verify Documents", DocumentVerificationService))
  #
  # Key features:
  # - Integration with task management services
  # - Automatic task creation when executed in a process
  #
  class StaffTask
    include Step

    attr_accessor :name, :task_management_service

    def initialize(name, task_management_service)
      @name = name
      @task_management_service = task_management_service
    end

    def execute(kase)
      @task_management_service.create_task(kase)
    end
  end
end
