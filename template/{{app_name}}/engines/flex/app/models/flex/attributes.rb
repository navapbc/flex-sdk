module Flex
  InvalidDate = Struct.new(:year, :month, :day) do
    # Convenience method to compare InvalidDate instances to Date objects or
    # Hash objects of the form { year: 2020, month: 1, day: 1 }
    def ==(other)
      case other
      when Hash
        # Transform keys to symboles so that comparison ignores whether keys are symbols or strings
        to_h == other.transform_keys(&:to_sym)
      else
        super
      end
    end
  end

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

          validates :"#{name}_year", numericality: { only_integer: true, allow_nil: true }
          validates :"#{name}_month",
            numericality: { only_integer: true, allow_nil: true },
            comparison: { greater_than_or_equal_to: 1, less_than_or_equal_to: 12, allow_nil: true }
          validates :"#{name}_day",
            numericality: { only_integer: true, allow_nil: true },
            comparison: { greater_than_or_equal_to: 1, less_than_or_equal_to: 31, allow_nil: true }

          composed_of name, class_name: "Date",
            mapping: {
              year_attribute => "year",
              month_attribute => "month",
              day_attribute => "day"
            },
            allow_nil: options[:allow_nil] || false,
            converter: Proc.new { |value|
              begin
                Date.new(value[:year], value[:month], value[:day])
              rescue Date::Error
                InvalidDate.new(**value)
              end
            }

          validate :"validate_#{name}"

          define_method "validate_#{name}" do
            value = send(name)
            return if value.nil?

            # If value is a Date, it is already valid
            return if value.is_a?(Date)

            # Assert that value is an instance of InvalidDate
            raise RuntimeError, "Expected #{name} to be an instance of InvalidDate but got #{value.class}" unless value.is_a?(InvalidDate)

            # InvalidDate is always invalid since it only gets created when Date.new raises an error
            errors.add(name, :invalid_date, message: "is not a valid date")
          end
        end
    end
  end
end
