module Flex
  module Rules
    class MedicaidRules < Base
      def medicaid_eligibility(state_of_residence, age_over_65, modified_adjusted_gross_income)
        age_over_65 && modified_adjusted_gross_income < 50000
      end

      def age(date_of_birth)
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

      def modified_adjusted_gross_income(annual_income, deductions)
        annual_income - deductions
      end
    end
  end
end
