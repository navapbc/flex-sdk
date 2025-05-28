require 'rails_helper'

module Flex
  module Rules
    RSpec.describe MedicaidRules do
      evaluated_on = Date.new(2025, 5, 28) # Freeze time for testing
      let(:rules) { described_class.new }

      describe '#medicaid_eligibility' do
        [
          [ "when applicant is over 65 with qualifying income", "AK", true, 35000, true ],
          [ "when applicant is over 65 but income is too high", "AK", true, 55000, false ],
          [ "when applicant is under 65", "AK", false, 35000, false ],
          [ "when state of residence is missing", nil, true, 35000, true ]
        ].each do |context_description, state, over_65, income, expected|
          context context_description do
            it 'determines correct medicaid eligibility' do
              expect(rules.medicaid_eligibility(state, over_65, income)).to be expected
            end
          end
        end
      end

      describe '#age' do
        [
          [ "calculates age correctly", Date.new(1954, 1, 1), evaluated_on, 71 ], # 71 years old in 2025
          [ "calculates age on birthday", Date.new(1954, 1, 1), Date.new(2004, 1, 1), 50 ],
          [ "handles leap years", Date.new(2000, 5, 29), Date.new(2025, 5, 28), 24 ],
          [ "returns nil when date of birth is nil", nil, evaluated_on, nil ],
          [ "handles birth dates near today", Date.new(Date.today.year - 65, Date.today.month, Date.today.day + 1), evaluated_on, 64 ],
          [ "returns nil when date of birth is after today", Date.today + 1.day, evaluated_on, nil ],
          [ "returns nil when evaluated_on is nil", Date.new(1954, 1, 1), nil, nil ]
        ].each do |description, birth_date, evaluated_on, expected|
          it description do
            expect(rules.age(birth_date, evaluated_on)).to expected.nil? ? be_nil : eq(expected)
          end
        end
      end

      describe '#age_over_65' do
        [
          [ "returns true when age is over 65", 71, true ],
          [ "returns true when age is exactly 65", 65, true ],
          [ "returns false when age is under 65", 64, false ],
          [ "returns nil when age is nil", nil, nil ]
        ].each do |description, age, expected|
          it description do
            expect(rules.age_over_65(age)).to be expected
          end
        end
      end

      describe '#state_of_residence' do
        [
          [ "returns state from residential address", Address.new("123 A St", "", "Anchorage", "AK", "12345"), "AK" ],
          [ "returns nil when address is nil", nil, nil ]
        ].each do |description, addr, expected|
          it description do
            expect(rules.state_of_residence(addr)).to expected.nil? ? be_nil : eq(expected)
          end
        end
      end

      describe '#modified_adjusted_gross_income' do
        [
          [ "subtracts deductions from annual income", 40000, 5000, 35000 ]
        ].each do |description, income, deductions, expected|
          it description do
            expect(rules.modified_adjusted_gross_income(income, deductions)).to eq(expected)
          end
        end
      end
    end
  end
end
