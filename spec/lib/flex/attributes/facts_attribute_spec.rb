require 'rails_helper'

module Flex
  module Attributes
    RSpec.describe FactsAttribute do
      let(:test_case) { TestCase.new }

      describe 'Facts container' do
        it 'provides hash-like interface' do
          facts = FactsAttribute::Facts.new
          fact = Flex::RulesEngine::Fact.new(:test_fact, 'test_value')

          facts[:test_fact] = fact
          expect(facts[:test_fact]).to eq(fact)
          expect(facts.keys).to include(:test_fact)
        end

        it 'converts simple values to Facts' do
          facts = FactsAttribute::Facts.new(test_fact: 'simple_value')
          result = facts[:test_fact]

          expect(result).to be_a(Flex::RulesEngine::Fact)
          expect(result.name).to eq(:test_fact)
          expect(result.value).to eq('simple_value')
          expect(result.created_at).to be_a(Time)
        end

        it 'serializes and deserializes correctly' do
          original_time = Time.parse('2025-01-01 12:00:00 UTC')
          fact = Flex::RulesEngine::Fact.new(:test_fact, 'test_value', created_at: original_time)
          facts = FactsAttribute::Facts.new(test_fact: fact)

          json = facts.to_json
          restored_facts = FactsAttribute::Facts.from_hash(JSON.parse(json))

          restored_fact = restored_facts[:test_fact]
          expect(restored_fact.name).to eq(:test_fact)
          expect(restored_fact.value).to eq('test_value')
          expect(restored_fact.created_at).to be_within(1.second).of(original_time)
        end

        it 'handles nested reasons correctly' do
          reason_fact = Flex::RulesEngine::Fact.new(:reason, 'reason_value')
          main_fact = Flex::RulesEngine::Fact.new(:main, 'main_value', reasons: [ reason_fact ])
          facts = FactsAttribute::Facts.new(main: main_fact)

          json = facts.to_json
          restored_facts = FactsAttribute::Facts.from_hash(JSON.parse(json))

          restored_main = restored_facts[:main]
          expect(restored_main.reasons.length).to eq(1)
          expect(restored_main.reasons.first.name).to eq(:reason)
          expect(restored_main.reasons.first.value).to eq('reason_value')
        end

        it 'handles empty facts' do
          facts = FactsAttribute::Facts.new
          expect(facts.empty?).to be true
          expect(facts.keys).to be_empty
          expect(facts.values).to be_empty
        end

        it 'supports each iteration' do
          facts = FactsAttribute::Facts.new(fact1: 'value1', fact2: 'value2')
          keys = []
          facts.each { |key, _| keys << key }
          expect(keys).to contain_exactly(:fact1, :fact2)
        end

        it 'converts to hash' do
          facts = FactsAttribute::Facts.new(test: 'value')
          hash = facts.to_h
          expect(hash).to be_a(Hash)
          expect(hash[:test]).to be_a(Flex::RulesEngine::Fact)
        end
      end

      describe 'FactsType' do
        let(:facts_type) { FactsAttribute::FactsType.new }

        it 'casts hash to Facts' do
          result = facts_type.cast(test_fact: 'value')
          expect(result).to be_a(FactsAttribute::Facts)
          expect(result[:test_fact].value).to eq('value')
        end

        it 'returns nil for nil input' do
          expect(facts_type.cast(nil)).to be_nil
        end

        it 'returns existing Facts unchanged' do
          facts = FactsAttribute::Facts.new(test: 'value')
          result = facts_type.cast(facts)
          expect(result).to eq(facts)
        end

        it 'serializes Facts to JSON' do
          facts = FactsAttribute::Facts.new(test: 'value')
          result = facts_type.serialize(facts)
          expect(result).to be_a(String)
          expect(JSON.parse(result)).to have_key('test')
        end

        it 'returns nil for nil serialization' do
          expect(facts_type.serialize(nil)).to be_nil
        end

        it 'deserializes JSON to Facts' do
          json = '{"test_fact":{"name":"test_fact","value":"test_value","reasons":[],"created_at":"2025-01-01T12:00:00Z"}}'
          result = facts_type.deserialize(json)
          expect(result).to be_a(FactsAttribute::Facts)
          expect(result[:test_fact].value).to eq('test_value')
        end

        it 'returns empty Facts for nil deserialization' do
          result = facts_type.deserialize(nil)
          expect(result).to be_a(FactsAttribute::Facts)
          expect(result.empty?).to be true
        end

        it 'returns empty Facts for blank deserialization' do
          result = facts_type.deserialize('')
          result = facts_type.deserialize('')
          expect(result).to be_a(FactsAttribute::Facts)
          expect(result.empty?).to be true
        end

        it 'has correct type' do
          expect(facts_type.type).to eq(:facts)
        end
      end

      describe 'integration with TestRecord' do
        let(:test_record) { TestRecord.new }

        it 'allows setting facts as hash' do
          test_record.test_facts = { eligibility: true }
          fact = test_record.test_facts[:eligibility]
          expect(fact).to be_a(Flex::RulesEngine::Fact)
          expect(fact.value).to be true
        end

        it 'allows setting facts as Facts object' do
          facts = FactsAttribute::Facts.new(eligibility: false)
          test_record.test_facts = facts
          expect(test_record.test_facts).to eq(facts)
        end

        it 'maintains backward compatibility with hash access' do
          test_record.test_facts = { result: 'approved' }
          expect(test_record.test_facts[:result].value).to eq('approved')
        end
      end
    end
  end
end
