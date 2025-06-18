module Flex
  # A generic rules engine that evaluates facts based on defined rules.
  # Uses dependency injection for rule sets and maintains a fact cache.
  class RulesEngine
    # Represents a computed or input fact in the rules engine.
    # Tracks the fact's name, value, and the reasons (dependencies) that led to its value.
    class Fact
      attr_reader :name, :value, :reasons, :created_at

      def initialize(name, value, reasons: [], created_at: Time.now)
        @name = name
        @value = value
        @reasons = reasons
        @created_at = created_at
      end

      def as_json(options = {})
        {
          name: name,
          value: value,
          reasons: reasons.map(&:as_json),
          created_at: created_at.iso8601
        }
      end

      def self.from_hash(hash)
        return hash unless hash.is_a?(Hash) && hash.key?("name")

        reasons = (hash["reasons"] || []).map { |reason_data| from_hash(reason_data) }
        created_at = hash["created_at"] ? Time.parse(hash["created_at"]) : Time.now

        new(
          hash["name"].to_sym,
          hash["value"],
          reasons: reasons,
          created_at: created_at
        )
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
