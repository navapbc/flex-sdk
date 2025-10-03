# frozen_string_literal: true

module Strata
  module TaskService
    # Strata::TaskService::Base is an abstract base class that defines the interface for services
    # that create and manage tasks.
    class Base
      # Creates a new task associated with the given case
      # @param task_class [Strata::Task] the task to create
      # @param kase [Strata::Case] the case to associate the task with
      # @return [Strata::Task] the newly created task
      def create_task(task_class, kase)
        raise NoMethodError, "#{self.class} must implement create_task method"
      end
    end
  end
end
