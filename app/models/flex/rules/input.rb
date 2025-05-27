module Flex
  module Rules
    class Input < DerivedFact
      def initialize(name, value)
        super(name, value, reasons: [])
      end
    end
  end
end
