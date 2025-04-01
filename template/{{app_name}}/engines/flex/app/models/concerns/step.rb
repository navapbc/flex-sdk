module Flex
  module Step
    extend ActiveSupport::Concern

    def execute(kase)
      raise NoMethodError, "#{self.class} must implement execute method"
    end
  end
end