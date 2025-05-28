module Flex
  module TaskService
    # Service class responsible for creating and managing tasks
    # Implements the TaskHandlerService interface
    class Database < Base
      def create_task(task, kase)
        raise ArgumentError, "`task` must be a Flex::Task or a subclass of Flex::Task" unless task.present? && task.is_a?(Flex::Task)
        raise ArgumentError, "`kase` must be a subclass of Flex::Case" unless kase.present && kase.is_a?(Flex::Case)
        task.create(case_id: kase.id)
      end
    end
  end
end
