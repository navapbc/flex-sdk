module Flex
  module Rules
    class MedicaidRules < Engine
      def medicaid_eligibility
        state = evaluate(:state_of_residence)
        age_over_65 = evaluate(:age_over_65)
        income = evaluate(:magi)
        
        eligible = age_over_65.value && income.value < 50000
        
        DerivedFact.new(:medicaid_eligibility, eligible, reasons: [state, age_over_65, income])
      end

      def age
        date_of_birth = get_fact(:date_of_birth)
        
        if date_of_birth.nil?
          value = nil
        else
          today = Date.today
          value = today.year - date_of_birth.year
          value -= 1 if today < date_of_birth + value.years
        end

        DerivedFact.new(:age, value, reasons: [Input.new(:date_of_birth, date_of_birth)])
      end

      def age_over_65
        age = evaluate(:age)
        DerivedFact.new(:age_over_65, age.value >= 65, reasons: [age])
      end

      def state_of_residence
        address = get_fact(:residential_address)
        DerivedFact.new(:state_of_residence, address&.state, reasons: [Input.new(:residential_address, address)])
      end

      def magi
        # Simplified MAGI calculation - would be more complex in reality
        income = get_fact(:annual_income) || 0
        deductions = get_fact(:deductions) || 0
        magi = income - deductions
        
        DerivedFact.new(:modified_adjusted_gross_income, magi, reasons: [
          Input.new(:annual_income, income),
          Input.new(:deductions, deductions)
        ])
      end
    end
  end
end
