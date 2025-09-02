module Flex
  module TaskService
    # Service class responsible for creating and managing tasks
    # Implements the TaskHandlerService interface
    class Database < Base
      def create_task(task_class, kase)
        raise ArgumentError, "`task_class` must be a Flex::Task or a subclass of Flex::Task" unless task_class.present? && task_class <= (Flex::Task)
        raise ArgumentError, "`kase` must be a subclass of Flex::Case" unless kase.present? && kase.is_a?(Flex::Case)
        kase.create_task(task_class)
      end
    end
  end
end
