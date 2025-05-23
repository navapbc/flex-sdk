module Flex
  module TaskService
    # Flex::TaskService::Base is an abstract base clsas that defines the interface for services
    # that create and manage tasks.
    class Base
      include Singleton

      # Creates a new task associated with the given case
      # @param kase [Flex::Case] the case to associate the task with
      # @return [Flex::Task] the newly created task
      def create_task(kase)
        raise NoMethodError, "#{self.class} must implement create_task method"
      end
    end      
  end
end
