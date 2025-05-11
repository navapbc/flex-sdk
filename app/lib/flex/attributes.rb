module Flex
  module Attributes
    extend ActiveSupport::Concern

    # A custom ActiveRecord type that allows storing a date as a string.
    # The attribute accepts a Date, a Hash with keys :year, :month, :day,
    # or a String in the format "YYYY-MM-DD".
    class DateFromHash < ActiveRecord::Type::Date
      # Accept a Date, a Hash of with keys :year, :month, :day,
      # or a String in the format "YYYY-MM-DD"
      # (the parts of the string don't have to be numeric or represent valid years/months/days
      # since the date will be validated separately)
      def cast(value)
        return super(value) unless value.is_a?(Hash)

        begin
          # Use strptime since Date.new is too lenient, allowing things like negative months and years
          value = Date.strptime("#{value[:year]}-#{value[:month]}-#{value[:day]}", "%Y-%m-%d")
        rescue ArgumentError
          nil
        end
      end

      def type
        :date_from_hash
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
          attribute name, DateFromHash.new

          validate :"validate_#{name}"

          if options[:presence]
            validates name, presence: true
          end

          # Create a validation method that checks if the value is a valid date
          define_method "validate_#{name}" do
            value = send(name)
            raw_value = read_attribute_before_type_cast(name)

            if raw_value.present? && value.nil?
              errors.add(name, :invalid_memorable_date)
            end
          end
        end
    end
  end
end
