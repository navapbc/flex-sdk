module Strata
  module TaskService
    # Service class responsible for creating and managing tasks
    # Implements the TaskHandlerService interface
    class Database < Base
      def create_task(task_class, kase)
        raise ArgumentError, "`task_class` must be a Strata::Task or a subclass of Strata::Task" unless task_class.present? && task_class <= (Strata::Task)
        raise ArgumentError, "`kase` must be a subclass of Strata::Case" unless kase.present? && kase.is_a?(Strata::Case)
        kase.create_task(task_class)
      end
    end
  end
end
