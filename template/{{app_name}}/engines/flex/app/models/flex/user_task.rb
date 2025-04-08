module Flex
  class UserTask
    include Step
    include ActiveModel::Model
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    attr_accessor :name

    validates :name, presence: true

    def initialize(task_management_service)
      @task_management_service = task_management_service
      # @task_management_service.create_task
    end

    def execute(kase)
      @task_management_service.create_task(name, "eventually will contain details about a case instead of static string")
    end
  end
end
