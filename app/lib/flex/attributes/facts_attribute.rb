module Flex
  module Attributes
    # FactsAttribute provides a DSL for defining facts attributes in case models.
    # It creates a jsonb field with custom serialization for Fact objects with timestamps.
    module FactsAttribute
      extend ActiveSupport::Concern

      # A custom ActiveRecord type that handles Facts container serialization
      class FactsType < ActiveRecord::Type::Value
        def cast(value)
          return nil if value.nil?
          return value if value.is_a?(Facts)

          case value
          when Hash
            Facts.new(value)
          else
            Facts.new
          end
        end

        def serialize(value)
          return nil if value.nil?
          return value.to_json if value.is_a?(Facts)
          value
        end

        def deserialize(value)
          return Facts.new if value.nil?
          return Facts.new if value.blank?

          facts_hash = JSON.parse(value)
          Facts.from_hash(facts_hash)
        end

        def type
          :facts
        end
      end

      # Container for facts with hash-like interface
      class Facts
        def initialize(facts_hash = {})
          @facts = {}
          facts_hash.each do |key, value|
            @facts[key.to_sym] = value.is_a?(Flex::RulesEngine::Fact) ? value : convert_to_fact(key, value)
          end
        end

        def [](key)
          @facts[key.to_sym]
        end

        def []=(key, value)
          @facts[key.to_sym] = value.is_a?(Flex::RulesEngine::Fact) ? value : convert_to_fact(key, value)
        end

        def each(&block)
          @facts.each(&block)
        end

        def keys
          @facts.keys
        end

        def values
          @facts.values
        end

        def to_h
          @facts.dup
        end

        def empty?
          @facts.empty?
        end

        def to_json
          serializable_hash = {}
          @facts.each do |key, fact|
            serializable_hash[key] = {
              name: fact.name,
              value: fact.value,
              reasons: serialize_reasons(fact.reasons),
              created_at: fact.created_at.iso8601
            }
          end
          JSON.generate(serializable_hash)
        end

        def self.from_hash(hash)
          facts = new
          hash.each do |key, fact_data|
            if fact_data.is_a?(Hash) && fact_data.key?("name")
              reasons = deserialize_reasons(fact_data["reasons"] || [])
              created_at = fact_data["created_at"] ? Time.parse(fact_data["created_at"]) : Time.now
              fact = Flex::RulesEngine::Fact.new(
                fact_data["name"].to_sym,
                fact_data["value"],
                reasons: reasons,
                created_at: created_at
              )
              facts[key] = fact
            else
              facts[key] = fact_data
            end
          end
          facts
        end

        private

        def convert_to_fact(key, value)
          if value.is_a?(Hash) && value.key?(:name)
            reasons = value[:reasons] || []
            created_at = value[:created_at] || Time.now
            Flex::RulesEngine::Fact.new(value[:name], value[:value], reasons: reasons, created_at: created_at)
          else
            Flex::RulesEngine::Fact.new(key, value, reasons: [], created_at: Time.now)
          end
        end

        def serialize_reasons(reasons)
          reasons.map do |reason|
            if reason.is_a?(Flex::RulesEngine::Fact)
              {
                name: reason.name,
                value: reason.value,
                reasons: serialize_reasons(reason.reasons),
                created_at: reason.created_at.iso8601
              }
            else
              reason
            end
          end
        end

        def self.deserialize_reasons(reasons_data)
          reasons_data.map do |reason_data|
            if reason_data.is_a?(Hash) && reason_data.key?("name")
              nested_reasons = deserialize_reasons(reason_data["reasons"] || [])
              created_at = reason_data["created_at"] ? Time.parse(reason_data["created_at"]) : Time.now
              Flex::RulesEngine::Fact.new(
                reason_data["name"].to_sym,
                reason_data["value"],
                reasons: nested_reasons,
                created_at: created_at
              )
            else
              reason_data
            end
          end
        end
      end

      class_methods do
        def facts_attribute(name, options = {})
          attribute name, FactsType.new
        end
      end
    end
  end
end
