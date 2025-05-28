require 'rails_helper'

module Flex
  module Rules
    RSpec.describe Base do
      let(:example_rules) {
        Class.new(described_class) do
          def age(date_of_birth)
            return nil if date_of_birth.nil?

            today = Date.new(2025, 5, 27)  # Freeze time for testing
            value = today.year - date_of_birth.year
            value -= 1 if today < date_of_birth + value.years
            value
          end

          def age_over_65(age)
            age >= 65 if age.present?
          end

          def age_over_18(age)
            age >= 18 if age.present?
          end
        end
      }

      describe '#evaluate' do
        let(:date_of_birth) { Date.new(1990, 1, 1) }  # 35 years old in 2025
        let(:rules) { example_rules.new(date_of_birth: date_of_birth) }

        it 'returns input facts directly' do
          result = rules.evaluate(:date_of_birth)
          expect(result).to be_a(Input)
          expect(result.value).to eq(date_of_birth)
          expect(result.reasons).to eq([])
        end

        it 'computes values derived from inputs' do
          result = rules.evaluate(:age)
          expect(result.value).to eq(35)
          expect(result.reasons).to contain_exactly(
            have_attributes(name: :date_of_birth, value: date_of_birth)
          )
        end

        it 'computes multiple levels of derived facts' do
          result = rules.evaluate(:age_over_18)
          expect(result.value).to be true
          expect(result.reasons).to contain_exactly(
            have_attributes(name: :age, value: 35),
          )
        end

        context 'when input is missing' do
          let(:rules) { example_rules.new({}) }

          it 'passes nil to rule' do
            result = rules.evaluate(:age)
            expect(result.value).to be_nil
            expect(result.reasons).to contain_exactly(
              have_attributes(name: :date_of_birth, value: nil)
            )
          end
        end

        context 'when fact method does not exist' do
          it 'returns nil value with empty reasons' do
            result = rules.evaluate(:nonexistent_fact)
            expect(result.value).to be_nil
            expect(result.reasons).to be_empty
          end
        end
      end
    end
  end
end
