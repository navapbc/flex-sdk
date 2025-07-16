module Flex
  module Types
    # Custom ActiveRecord type for Flex name attributes
    # Handles casting and serialization of Flex::Name objects
    class NameType < ActiveRecord::Type::Value
      def cast(value)
        case value
        when Flex::Name
          value
        when Hash
          Flex::Name.new(
            first: value[:first] || value["first"],
            middle: value[:middle] || value["middle"],
            last: value[:last] || value["last"]
          )
        when nil
          nil
        else
          Flex::Name.new(first: value.to_s)
        end
      end

      def serialize(value)
        return nil unless value
        return value if value.is_a?(String)
        value.to_s
      end
    end
  end
end
