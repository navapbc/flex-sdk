require 'rails_helper'

module Flex
  module Rules
    RSpec.describe MedicaidRules do
      let(:date_of_birth) { Date.new(1954, 1, 1) }  # 71 years old in 2025
      let(:address) { Address.new("123 A St", "", "Anchorage", "AK", "12345") }
      let(:facts) do
        {
          date_of_birth: date_of_birth,
          residential_address: address,
          annual_income: 40000,
          deductions: 5000
        }
      end
      let(:engine) { described_class.new(facts) }

      describe 'medicaid eligibility rules' do
        context 'when applicant is over 65 with qualifying income' do
          it 'determines eligible for medicaid' do
            result = engine.evaluate(:medicaid_eligibility)
            expect(result.value).to be true
            expect(result.reasons).to contain_exactly(
              have_attributes(name: :state_of_residence, value: "AK"),
              have_attributes(name: :age_over_65, value: true),
              have_attributes(name: :magi, value: 35000)
            )
          end
        end

        context 'when applicant is over 65 but income is too high' do
          let(:facts) do
            {
              date_of_birth: date_of_birth,
              residential_address: address,
              annual_income: 60000,
              deductions: 5000
            }
          end

          it 'determines not eligible for medicaid' do
            result = engine.evaluate(:medicaid_eligibility)
            expect(result.value).to be false
            expect(result.reasons).to contain_exactly(
              have_attributes(name: :state_of_residence, value: "AK"),
              have_attributes(name: :age_over_65, value: true),
              have_attributes(name: :magi, value: 55000)
            )
          end
        end

        context 'when applicant is under 65' do
          let(:date_of_birth) { Date.new(1990, 1, 1) }  # 35 years old in 2025

          it 'determines not eligible for medicaid' do
            result = engine.evaluate(:medicaid_eligibility)
            expect(result.value).to be false
            expect(result.reasons).to contain_exactly(
              have_attributes(name: :state_of_residence, value: "AK"),
              have_attributes(name: :age_over_65, value: false),
              have_attributes(name: :magi, value: 35000)
            )
          end
        end

        context 'when state of residence is missing' do
          let(:facts) do
            {
              date_of_birth: date_of_birth,
              annual_income: 40000,
              deductions: 5000
            }
          end

          it 'includes nil state in reasons' do
            result = engine.evaluate(:medicaid_eligibility)
            expect(result.reasons.first).to have_attributes(
              name: :state_of_residence,
              value: nil
            )
          end
        end

        context 'when using pre-computed age' do
          let(:facts) do
            {
              age: 70,
              residential_address: address,
              annual_income: 40000,
              deductions: 5000
            }
          end

          it 'uses provided age instead of calculating from date of birth' do
            result = engine.evaluate(:medicaid_eligibility)
            expect(result.value).to be true
            expect(result.reasons).to include(
              have_attributes(name: :age_over_65, value: true)
            )
          end
        end
      end
    end
  end
end
