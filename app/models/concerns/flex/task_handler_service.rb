module Flex
  # TaskHandlerService is a concern that defines the interface for services
  # that create and manage tasks.
  #
  # This module is included by task management services to provide a
  # common interface for creating tasks from business process steps.
  #
  module TaskHandlerService
    extend ActiveSupport::Concern

    def create_task(kase)
      raise NoMethodError, "#{self.class} must implement create_task method"
    end
  end
end
