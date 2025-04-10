module Flex
  class UserTask
    include Step

    attr_accessor :name, :task_management_service

    def initialize(name:, task_management_service:)
      @name = name
      @task_management_service = task_management_service
    end

    def execute(kase)
      @task_management_service.create_task(name, "eventually will contain details about a case instead of static string")
    end
  end
end
