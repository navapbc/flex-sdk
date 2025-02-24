module Eligibility
  module Rules
    class BaseEligibilityRule
      def evaluate
        raise NotImplementedError, "'evaluate' method is mandatory"
      end
    end
  end
end
