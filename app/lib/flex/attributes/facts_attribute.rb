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
        extend Forwardable
        def_delegators :@facts, :each, :keys, :values, :empty?

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

        def to_h
          @facts.dup
        end

        def as_json(options = {})
          @facts
        end

        def self.from_hash(hash)
          new(hash.transform_values do |value|
            Flex::RulesEngine::Fact.from_hash(value)
          end)
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
      end

      class_methods do
        def facts_attribute(name, options = {})
          attribute name, FactsType.new
        end
      end
    end
  end
end
