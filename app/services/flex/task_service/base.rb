module Flex
  module TaskService
    # Flex::TaskService::Base is an abstract base class that defines the interface for services
    # that create and manage tasks.
    class Base
      # Creates a new task associated with the given case
      # @param task [Flex::Task] the task to create
      # @param kase [Flex::Case] the case to associate the task with
      # @return [Flex::Task] the newly created task
      def create_task(task, kase)
        raise NoMethodError, "#{self.class} must implement create_task method"
      end
    end
  end
end
