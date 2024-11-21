require_relative 'base_eligibility_rule'

module Eligibility
  module Rules
    class MinimumWagesRule < BaseEligibilityRule
      def initialize(params = {})
        @threshold = params.fetch('threshold', 5000)
      end

      def evaluate(employee, claim)
        puts @threshold
        employee[:wages] >= @threshold
      end
    end
  end 
end