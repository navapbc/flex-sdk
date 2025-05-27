module Flex
  module Rules
    class DerivedFact
      attr_reader :name, :value, :reasons

      def initialize(name, value, reasons: [])
        @name = name
        @value = value
        @reasons = reasons
      end
    end
  end
end
