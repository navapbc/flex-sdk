module Flex
  class InvalidDate
    include ActiveModel::Model

    attr_accessor :year, :month, :day
    validates :year, numericality: { only_integer: true, allow_nil: true }
    validates :month,
      numericality: { only_integer: true, allow_nil: true },
      comparison: { greater_than_or_equal_to: 1, less_than_or_equal_to: 12, allow_nil: true }
    validates :day,
      numericality: { only_integer: true, allow_nil: true },
      comparison: { greater_than_or_equal_to: 1, less_than_or_equal_to: 31, allow_nil: true }

    # Convenience method to compare InvalidDate instances to Date objects or
    # Hash objects of the form { year: 2020, month: 1, day: 1 }
    def ==(other)
      case other
      when Hash
        # Transform keys to strings so that comparison ignores whether keys are symbols or strings
        other = other.transform_keys(&:to_s)
        as_json.to_h.slice("year", "month", "day") == other
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

            if !value.valid?
              # If any of the individual date attributes are invalid, add errors to the model
              value.errors.each do |e|
                errors.add("#{name}_#{e.attribute}", e.type, message: e.message)
              end
            else
              # If the invalid date is valid, that means each attribute is valid but the overall date is still not valid
              errors.add(name, :invalid_date, message: "is not a valid date")
            end
          end
        end
    end
  end
end
