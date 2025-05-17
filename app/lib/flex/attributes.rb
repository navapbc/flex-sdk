module Flex
  module Attributes
    extend ActiveSupport::Concern
    include Flex::Attributes::MemorableDateAttribute
    include Flex::Attributes::NameAttribute

    class_methods do
      def flex_attribute(name, type, options = {})
        case type
        when :memorable_date
          memorable_date_attribute name, options
        when :name
          name_attribute name, options
        else
          raise ArgumentError, "Unsupported attribute type: #{type}"
        end
      end
    end
  end
end
