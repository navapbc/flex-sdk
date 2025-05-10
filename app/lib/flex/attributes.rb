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

    # A custom ActiveRecord type that allows storing a date range.
    # This type handles the conversion between various input formats and a Ruby Range object.
    class DateRangeType < ActiveRecord::Type::Value
      def cast(value)
        return nil if value.nil?

        case value
        when Range
          if value.begin.is_a?(Date) && value.end.is_a?(Date)
            value
          else
            begin
              Date.parse(value.begin.to_s)..Date.parse(value.end.to_s)
            rescue Date::Error
              raise ArgumentError, "Invalid date range: #{value.inspect}. Expected Range with valid Date objects."
            end
          end
        when Hash
          if value[:start].present? && value[:end].present?
            begin
              start_date = cast_date_value(value[:start])
              end_date = cast_date_value(value[:end])
              start_date..end_date
            rescue Date::Error
              raise ArgumentError, "Invalid date range: #{value.inspect}. Expected Hash with valid :start and :end dates."
            end
          elsif value[:start].nil? && value[:end].nil?
            nil
          else
            raise ArgumentError, "Invalid date range: #{value.inspect}. Both start and end must be present or both must be nil."
          end
        else
          raise ArgumentError, "Invalid value for date range: #{value.inspect}. Expected Range or Hash with :start and :end keys."
        end
      end

      def type
        :date_range
      end

      private

      def cast_date_value(value)
        case value
        when Date
          value
        when Hash
          year = value[:year].to_s
          month = value[:month].to_s
          day = value[:day].to_s
          Date.parse("#{year}-#{month}-#{day}")
        when String
          Date.parse(value)
        else
          raise ArgumentError, "Invalid date value: #{value.inspect}. Expected Date, Hash, or String."
        end
      end
    end

    class_methods do
      def flex_attribute(name, type, options = {})
        if type == :memorable_date
          memorable_date_attribute name, options
        elsif type == :date_range
          date_range_attribute name, options
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

        def date_range_attribute(name, options)
          # Add validation for the range
          validate :"validate_#{name}_range"

          # Set up the composed_of relationship for ActiveRecord models
          if self <= ActiveRecord::Base
            composed_of name,
              class_name: 'Range',
              mapping: [
                ["#{name}_start", "begin"],
                ["#{name}_end", "end"]
              ],
              allow_nil: true,
              constructor: Proc.new { |start_date, end_date| 
                if start_date.nil? || end_date.nil?
                  nil
                else
                  start_date..end_date
                end
              },
              converter: Proc.new { |value| 
                if value.nil?
                  nil
                elsif value.is_a?(Range) && value.begin.is_a?(Date) && value.end.is_a?(Date)
                  value
                elsif value.is_a?(Hash) && value[:start].present? && value[:end].present?
                  Date.parse(value[:start].to_s)..Date.parse(value[:end].to_s)
                else
                  nil
                end
              }
          else
            # For non-ActiveRecord models (like in tests), provide basic attribute functionality
            attribute "#{name}_start", :date
            attribute "#{name}_end", :date

            # Define getter method for the range
            define_method name do
              start_date = send("#{name}_start")
              end_date = send("#{name}_end")

              # Return nil if both start and end are nil
              return nil if start_date.nil? && end_date.nil?

              # If only one is nil, the validation will catch this, but we need to return something
              return nil if start_date.nil? || end_date.nil?

              # Return a Range with the start and end dates
              start_date..end_date
            end

            # Define setter method for the range
            define_method "#{name}=" do |value|
              return if value.nil?

              case value
              when Range
                if value.begin.is_a?(Date) && value.end.is_a?(Date)
                  send("#{name}_start=", value.begin)
                  send("#{name}_end=", value.end)
                else
                  begin
                    start_date = Date.parse(value.begin.to_s)
                    end_date = Date.parse(value.end.to_s)
                    send("#{name}_start=", start_date)
                    send("#{name}_end=", end_date)
                  rescue Date::Error
                    # Invalid date, will be caught by validation
                    send("#{name}_start=", nil)
                    send("#{name}_end=", nil)
                  end
                end
              when Hash
                if value[:start].present? && value[:end].present?
                  begin
                    start_date = value[:start].is_a?(Date) ? value[:start] : Date.parse(value[:start].to_s)
                    end_date = value[:end].is_a?(Date) ? value[:end] : Date.parse(value[:end].to_s)
                    send("#{name}_start=", start_date)
                    send("#{name}_end=", end_date)
                  rescue Date::Error
                    # Invalid date, will be caught by validation
                    send("#{name}_start=", nil)
                    send("#{name}_end=", nil)
                  end
                elsif value[:start].nil? && value[:end].nil?
                  send("#{name}_start=", nil)
                  send("#{name}_end=", nil)
                end
              else
                # Invalid value, will be caught by validation
                send("#{name}_start=", nil)
                send("#{name}_end=", nil)
              end
            end
          end

          # Create validation method for the range
          define_method "validate_#{name}_range" do
            start_date = send("#{name}_start")
            end_date = send("#{name}_end")

            # Allow both nil (entire range is nil) but not one nil and one present
            if (start_date.nil? && !end_date.nil?) || (!start_date.nil? && end_date.nil?)
              errors.add(name, :invalid_date_range_nil)
              return
            end

            # Skip validation if both are nil
            return if start_date.nil? && end_date.nil?

            # Validate that start date is less than or equal to end date
            if start_date > end_date
              errors.add(name, :invalid_date_range)
            end
          end
        end
    end
  end
end
