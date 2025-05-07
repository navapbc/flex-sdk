module Flex
  module Attributes
    extend ActiveSupport::Concern

    # This class defines a string that represents a date in the format "<YEAR>-<MM>-<DD>"
    # and is designed to also allow invalid dates such as "2020-13-32" to facilitate
    # storing user input before validation.
    # Validation is handled separately to ensure that the date is valid
    #
    # The class also has nested attributes for year, month, and day to facilitate
    # treating the date as a structured value object which is useful for form building.
    class DateString < ::String
      attr_reader :year, :month, :day

      def initialize(year, month, day)
        @year, @month, @day = year, month, day
        super("#{year}-#{month.rjust(2, "0")}-#{day.rjust(2, "0")}")
      end
    end

    # A custom ActiveRecord type that allows storing a date as a string.
    # The attribute accepts a Date, a Hash with keys :year, :month, :day,
    # or a String in the format "YYYY-MM-DD".
    class DateStringType < ActiveRecord::Type::String
      # Accept a Date, a Hash of with keys :year, :month, :day,
      # or a String in the format "YYYY-MM-DD"
      # (the parts of the string don't have to be numeric or represent valid years/months/days
      # since the date will be validated separately)
      def cast(value)
        return nil if value.nil?

        year, month, day = case value
        when Date
          [ value.year.to_s, value.month.to_s, value.day.to_s ]
        when Hash
          [ value[:year].to_s, value[:month].to_s, value[:day].to_s ]
        when String
          if match = value.match(/(\w+)-(\w+)-(\w+)/)
            match.captures
          else
            raise ArgumentError, "Invalid date string format: #{value.inspect}. Expected format is '<YEAR>-<MONTH>-<DAY>'."
          end
        else
          raise ArgumentError, "Invalid value for #{name}: #{value.inspect}. Expected Date, Hash, or String."
        end

        DateString.new(year, month, day)
      end

      def type
        :date_string
      end
    end

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
          attribute name, DateStringType.new

          validate :"validate_#{name}"

          if options[:presence]
            validates name, presence: true
          end

          # Create a validation method that checks if the value is a valid date
          define_method "validate_#{name}" do
            value = send(name)
            return if value.nil?

            begin
              Date.strptime(value, "%Y-%m-%d")
            rescue Date::Error
              errors.add(name, :invalid_date, message: "is not a valid date")
            end
          end
        end
    end
  end
end
