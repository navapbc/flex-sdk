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
          # Create the start and end date attributes
          attribute "#{name}_start", :date
          attribute "#{name}_end", :date

          # Add validation for the range
          validate :"validate_#{name}"

          # Set up the composed_of relationship if we're in an ActiveRecord model
          if respond_to?(:composed_of)
            composed_of name,
              class_name: "Range",
              mapping: [
                [ "#{name}_start", "begin" ],
                [ "#{name}_end", "end" ]
              ],
              allow_nil: true,
              converter: Proc.new { |value|
                case value
                when Hash
                  if value[:start].present? && value[:end].present?
                    Date.parse(value[:start].to_s)..Date.parse(value[:end].to_s)
                  else
                    nil
                  end
                else
                  value
                end
              }
          else
            # For non-ActiveRecord models, define getter and setter methods
            define_method(name) do
              start_date = send("#{name}_start")
              end_date = send("#{name}_end")
              
              return nil if start_date.nil? && end_date.nil?
              start_date..end_date
            end
            
            define_method("#{name}=") do |value|
              case value
              when Range
                send("#{name}_start=", value&.begin)
                send("#{name}_end=", value&.end)
              when Hash
                if value[:start].present? && value[:end].present?
                  send("#{name}_start=", Date.parse(value[:start].to_s))
                  send("#{name}_end=", Date.parse(value[:end].to_s))
                else
                  send("#{name}_start=", nil)
                  send("#{name}_end=", nil)
                end
              when nil
                send("#{name}_start=", nil)
                send("#{name}_end=", nil)
              else
                raise ArgumentError, "Invalid value for #{name}: #{value.inspect}. Expected Range, Hash, or nil."
              end
            end
          end

          # Create validation method for the range
          define_method "validate_#{name}" do
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
