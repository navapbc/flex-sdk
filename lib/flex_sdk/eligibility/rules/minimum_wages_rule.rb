require_relative 'base_eligibility_rule'

module Eligibility
    module Rules
        class MinimumWagesRule < BaseEligibilityRule

            def initialize(params = {})
            puts params
            puts "--------"
                @threshold = params.fetch('threshold', 5000) # Default to 5000 if not specified
            end

            def evaluate(employee, claim)
                puts @threshold
                employee[:wages] >= @threshold #Placeholder logic/definitions
            end
        end
    end 
end