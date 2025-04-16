module Flex
  module TaskHandlerService
    extend ActiveSupport::Concern

    def create_task(kase)
      raise NoMethodError, "#{self.class} must implement execute method"
    end
  end
end
