module Flex
  module TaskService
    # Service class responsible for creating and managing tasks
    # Implements the TaskHandlerService interface
    class TaskService::Database < Flex::TaskService::Base
      def create_task(kase)
        raise ArgumentError, "Case can't be blank" if kase.nil?
        Flex::Task.create(case_id: kase.id)
      end
    end
  end
end
