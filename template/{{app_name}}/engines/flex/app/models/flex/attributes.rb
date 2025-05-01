module Flex
  module Attributes
    extend ActiveSupport::Concern

    class DateString < ::String

      def year
        parts[0]
      end

      def month
        parts[1].sub(/^0+/, "") # Remove leading zeros
      end

      def day
        parts[2].sub(/^0+/, "") # Remove leading zeros
      end

      private
        def parts
          if result = match(/(\w+)-(\w+)-(\w+)/)
            result.captures
          else
            raise RuntimeError, "Invalid date string format: #{self}. Expected format is '<YEAR>-<MONTH>-<DAY>'."
          end
        end
    end

    class DateStringType < ActiveRecord::Type::String
      # Accept a Date,  a Hash of with keys :year, :month, :day,
      # or a String in the format "YYYY-MM-DD"
      # (the parts of the string don't have to be numeric or represent valid years/months/days
      # since the date will be validated separately)
      def cast(value)
        return nil if value.nil?

        string = case value
        when Date
          super(value.strftime("%Y-%m-%d"))
        when Hash
          # Pad with zeros if necessary
          year = value[:year].to_s.rjust(4, "0")
          month = value[:month].to_s.rjust(2, "0")
          day = value[:day].to_s.rjust(2, "0")
          super("#{year}-#{month}-#{day}")
        when String
          if match = value.match(/(\w+)-(\w+)-(\w+)/)
            year, month, day = match.captures
            super("#{year}-#{month}-#{day}")
          else
            raise ArgumentError, "Invalid date string format: #{value.inspect}. Expected format is '<YEAR>-<MONTH>-<DAY>'."
          end
        else
          raise ArgumentError, "Invalid value for #{name}: #{value.inspect}. Expected Date, Hash, or String."
        end

        DateString.new(string)
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
