module Flex
  module Attributes
    extend ActiveSupport::Concern

    # A custom ActiveRecord type that allows storing a date. It behaviors the same
    # as the default Date type, but it allows setting the attribute using a hash
    # with keys :year, :month, and :day. This is meant to be used in conjunction
    # with the memorable_date method in the Flex form builder
    class MemorableDate < ActiveRecord::Type::Date
      # Override cast to allow setting the date via a Hash with keys :year, :month, :day.
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
          attribute name, MemorableDate.new

          validate :"validate_#{name}"

          if options[:presence]
            validates name, presence: true
          end

          # Create a validation method that checks if the value is a valid date
          define_method "validate_#{name}" do
            value = send(name)
            raw_value = read_attribute_before_type_cast(name)

            # If model.<attribute> is nil, but model.<attribute>_before_type_cast is not nil,
            # that means the application failed to cast the value to the appropriate type in
            # order to complete the attribute assignment. This means the original value
            # is invalid.
            did_type_cast_fail = value.nil? && raw_value.present?
            if did_type_cast_fail
              errors.add(name, :invalid_memorable_date)
            end
          end
        end
    end
  end
end
