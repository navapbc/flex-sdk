module Flex
  module Rules
    class Engine
      attr_reader :facts

      def initialize(facts)
        @facts = facts.map do |name, value|
          [name, Input.new(name, value)]
        end.to_h
      end

      def get_fact(name)
        @facts[name]&.value if @facts.key?(name)
      end

      def evaluate(fact_name)
        return @facts[fact_name] if @facts.key?(fact_name)
        
        result = compute_fact(fact_name)
        @facts[fact_name] = result
        result
      end

      protected

      def create_fact(name, value, reasons: [])
        @facts[name] = DerivedFact.new(name, value, reasons: reasons)
      end

      private

      def compute_fact(fact_name)
        send(fact_name)
      end
    end
  end
end
