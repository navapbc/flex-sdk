module Eligibility 
  module Rules
    class CustomRule < BaseEligibilityRule
      def initialize(params = {})
        @field = params.fetch('field').to_sym
        @operator = params.fetch('operator')
        @value = params.fetch('value')
      end

      def evaluate(employee, claim)
        target = employee[@field] || claim[@field]
        raise "Field #{@field} not found in employee or claim" if target.nil?

        target.send(@operator, @value)
      end
    end
  end
end