module Flex
  # Service class responsible for creating and managing tasks
  # Implements the TaskHandlerService interface
  class DatabaseTaskService
    include Singleton
    include Flex::TaskHandlerService

    # Creates a new task associated with the given case
    # @param kase [Flex::Case] the case to associate the task with
    # @return [Flex::Task] the newly created task
    def create_task(kase)
      Flex::Task.create(case_id: kase.id)
    end
  end
end
