# frozen_string_literal: true

require 'rails_helper'

module Strata
  RSpec.describe RulesEngine do
    let(:example_ruleset) {
      Class.new do
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
      end.new
    }
    let(:rules_engine) { described_class.new(example_ruleset) }

    describe '#evaluate' do
      let(:date_of_birth) { Date.new(1990, 1, 1) }  # 35 years old in 2025

      before do
        rules_engine.set_facts(date_of_birth: date_of_birth)
      end

      it 'returns input facts directly' do
        result = rules_engine.evaluate(:date_of_birth)
        expect(result).to be_a(RulesEngine::Fact)
        expect(result.value).to eq(date_of_birth)
        expect(result.reasons).to eq([])
      end

      it 'computes values derived from inputs' do
        result = rules_engine.evaluate(:age)
        expect(result.value).to eq(35)
        expect(result.reasons).to contain_exactly(
          have_attributes(name: :date_of_birth, value: date_of_birth)
        )
      end

      it 'computes multiple levels of derived facts' do
        result = rules_engine.evaluate(:age_over_18)
        expect(result.value).to be true
        expect(result.reasons).to contain_exactly(
          have_attributes(name: :age, value: 35),
        )
      end

      context 'when input is missing' do
        before do
          rules_engine.set_facts(date_of_birth: nil)
        end

        it 'passes nil to rule' do
          result = rules_engine.evaluate(:age)
          expect(result.value).to be_nil
          expect(result.reasons).to contain_exactly(
            have_attributes(name: :date_of_birth, value: nil)
          )
        end
      end

      context 'when fact method does not exist' do
        it 'returns nil value with empty reasons' do
          result = rules_engine.evaluate(:nonexistent_fact)
          expect(result.value).to be_nil
          expect(result.reasons).to be_empty
        end
      end
    end
  end
end
