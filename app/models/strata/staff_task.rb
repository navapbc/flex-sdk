# frozen_string_literal: true

module Strata
  # StaffTask represents a task that requires human interaction.
  # It is used in business processes to create tasks that staff members
  # need to complete manually.
  #
  # StaffTask uses a task management service to create tasks when executed
  # within a business process.
  #
  # @example Defining a staff task in a business process
  #   bp.step('verify_documents',
  #     Strata::StaffTask.new(MedicaidVerificationTask, Strata::TaskService.get))
  #
  # Key features:
  # - Integration with task management services
  # - Automatic task creation when executed in a process
  #
  class StaffTask
    include Step

    def initialize(task_class, task_management_service)
      raise ArgumentError, "`task_class` must be a Strata::Task or a subclass of Strata::Task" unless task_class.present? && task_class <= (Strata::Task)
      @task_class = task_class
      @task_management_service = task_management_service
    end

    def execute(kase)
      @task_management_service.create_task(@task_class, kase)
    end
  end
end
