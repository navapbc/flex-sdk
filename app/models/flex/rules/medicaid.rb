module Flex
  module Rules
    class MedicaidRules < Engine
      def evaluate_medicaid_eligibility
        state = evaluate(:state_of_residence)
        age_over_65 = evaluate(:age_over_65)
        income = evaluate(:modified_adjusted_gross_income)

        # This is a simplified example - actual Medicaid eligibility rules would be more complex
        eligible = age_over_65.value && income.value < 50000

        DerivedFact.new(:medicaid_eligibility, eligible, reasons: [ state, age_over_65, income ])
      end

      def evaluate_age
        return facts[:age] if facts.key?(:age)

        dob = facts[:date_of_birth]
        return nil unless dob

        age = ((Date.today - dob) / 365.25).floor
        DerivedFact.new(:age, age, reasons: [ Input.new(:date_of_birth, dob) ])
      end

      def evaluate_age_over_65
        age = evaluate(:age)
        DerivedFact.new(:age_over_65, age.value >= 65, reasons: [ age ])
      end

      def evaluate_state_of_residence
        return facts[:state_of_residence] if facts.key?(:state_of_residence)

        address = facts[:residential_address]
        return nil unless address

        DerivedFact.new(:state_of_residence, address.state, reasons: [ Input.new(:residential_address, address) ])
      end

      def evaluate_magi
        # Simplified MAGI calculation - would be more complex in reality
        income = facts[:annual_income] || 0
        deductions = facts[:deductions] || 0
        magi = income - deductions

        DerivedFact.new(:modified_adjusted_gross_income, magi, reasons: [
          Input.new(:annual_income, income),
          Input.new(:deductions, deductions)
        ])
      end
    end
  end
end
