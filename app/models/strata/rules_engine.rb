# frozen_string_literal: true

module Strata
  # A generic rules engine that evaluates facts based on defined rules.
  # Uses dependency injection for rule sets and maintains a fact cache.
  class RulesEngine
    # Represents a computed or input fact in the rules engine.
    # Tracks the fact's name, value, and the reasons (dependencies) that led to its value.
    class Fact
      attr_reader :name, :value, :reasons

      def initialize(name, value, reasons: [])
        @name = name
        @value = value
        @reasons = reasons
      end
    end

    def initialize(rules)
      @rules = rules
      @facts = {}
    end

    def set_facts(facts)
      facts.each do |name, value|
        @facts[name] = RulesEngine::Input.new(name, value)
      end
    end

    def evaluate(fact_name)
      return @facts[fact_name] if @facts.key?(fact_name)

      result = compute_fact(fact_name)
      @facts[fact_name] = result
      result
    end

    private

    # Represents an input fact with no dependencies.
    # Used for facts that are directly set rather than computed from other facts.
    class Input < Fact
      def initialize(name, value)
        super(name, value, reasons: [])
      end
    end

    def compute_fact(fact_name)
      if !@rules.respond_to?(fact_name)
        return Fact.new(fact_name, nil, reasons: [])
      end
      func = @rules.method(fact_name)
      func_inputs = func.parameters.map { |type, name| name }
      args = func_inputs.map { |name| evaluate(name)&.value }
      result = func.call(*args)
      Fact.new(fact_name, result, reasons: func_inputs.map { |name| @facts[name] })
    end
  end
end
