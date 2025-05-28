module Flex
  module Rules
    class MedicaidRules < Engine
      def medicaid_eligibility(state_of_residence, age_over_65, magi)
        age_over_65 && magi < 50000
      end

      def age(date_of_birth)
        date_of_birth = get_fact(:date_of_birth)
        
        return nil if date_of_birth.nil?

        today = Date.today
        value = today.year - date_of_birth.year
        value -= 1 if today < date_of_birth + value.years
        value
      end

      def age_over_65(age)
        age >= 65
      end

      def state_of_residence(residential_address)
        residential_address&.state
      end

      def magi(annual_income, deductions)
        annual_income - deductions
      end
    end
  end
end
