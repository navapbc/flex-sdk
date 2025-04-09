module Flex
  module Step
    extend ActiveSupport::Concern

    class_methods do
      def execute(kase)
        raise NoMethodError, "#{self.class} must implement execute method"
      end
    end
  end
end
