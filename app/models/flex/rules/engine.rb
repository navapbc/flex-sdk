module Flex
  module Rules
    class Engine
      attr_reader :facts

      def initialize(facts)
        @facts = facts.map do |name, value|
          [ name, Input.new(name, value) ]
        end.to_h
      end

      def evaluate(fact_name)
        return @facts[fact_name] if @facts.key?(fact_name)

        result = compute_fact(fact_name)
        @facts[fact_name] = result
        result
      end

      private

      def compute_fact(fact_name)
        if !respond_to?(fact_name)
          return DerivedFact.new(fact_name, nil, reasons: [])
        end
        func = method(fact_name)
        func_inputs = func.parameters.map { |type, name| name }
        args = func_inputs.map { |name| evaluate(name)&.value }
        result = func.call(*args)
        DerivedFact.new(fact_name, result, reasons: func_inputs.map { |name| @facts[name] })
      end
    end
  end
end
