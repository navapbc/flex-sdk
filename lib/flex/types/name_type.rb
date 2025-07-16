require "json"

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

      def deserialize(value)
        return nil unless value

        # Try to parse as JSON first (for database storage)
        if value.is_a?(String) && value.start_with?("{")
          begin
            parsed = JSON.parse(value)
            return cast(parsed) if parsed.is_a?(Hash)
          rescue JSON::ParserError
            # Fall through to treat as plain string
          end
        end

        # Treat as plain string and create Name with first name only
        cast(value)
      end
    end
  end
end
