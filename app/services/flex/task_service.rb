module Flex
  module TaskService
    mattr_accessor :service

    def self.set(service)
      self.service = service
    end

    def self.get
      if self.service.nil?
        # Other ideas for adapters: asana, jira, salesforce, trello
        # In the future, we can determine the task service based on the environment
        # e.g. something like task_service_name = ENV["TASK_SERVICE"] || "Flex::TaskService::Database"
        # self.service = task_service_name.constantize.new
        self.service = Flex::TaskService::Database.new
      end

      self.service
    end
  end
end
