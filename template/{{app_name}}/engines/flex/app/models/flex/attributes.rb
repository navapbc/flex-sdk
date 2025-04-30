module Flex
  module Attributes
    extend ActiveSupport::Concern

    class_methods do
      def flex_attribute(name, type, options = {})
        if type == :memorable_date
          memorable_date_attribute name, options
        else
          raise ArgumentError, "Unsupported attribute type: #{type}"
        end
      end

      private

        def memorable_date_attribute(name, options)
          year_attribute = "#{name}_year"
          month_attribute = "#{name}_month"
          day_attribute = "#{name}_day"

          attribute year_attribute, :integer, default: nil
          attribute month_attribute, :integer, default: nil
          attribute day_attribute, :integer, default: nil
          composed_of name, class_name: "Date",
            mapping: {
              year_attribute => "year",
              month_attribute => "month",
              day_attribute => "day"
            },
            allow_nil: options[:allow_nil] || false,
            converter: Proc.new { |value|
              Date.new(value[:year], value[:month], value[:day]) if value.is_a?(Hash)
            }
        end
    end
  end
end
