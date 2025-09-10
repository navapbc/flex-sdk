module Flex
  module Attributes
    # This module provides a custom ActiveRecord type for handling dates in a US format.
    # It allows dates to be stored in a format that is consistent with US conventions
    module USDateAttribute
      extend ActiveSupport::Concern

      # Module-level attribute type identifier
      def self.attribute_type
        :single_column_value_object
      end

      # A custom ActiveRecord type that allows storing a date. It behaviors the same
      # as the default Date type, but when casting a string it uses the US regional
      # format (MM/DD/YYYY) instead of default heuristics used by Date.parse which can
      # incorrectly interpret dates as DD/MM/YYYY.
      class USDateType < ActiveModel::Type::Date
        # Override cast to allow setting the date via a Hash with keys :year, :month, :day.
        def cast(value)
          Flex::USDate.cast(value)
        end

        def type
          :us_date
        end
      end

      class_methods do
        def us_date_attribute(name, options)
          attribute name, USDateType.new

          validate :"validate_#{name}"

          # Create a validation method that checks if the value is a valid date
          define_method "validate_#{name}" do
            value = send(name)
            raw_value = @attributes[name.to_s]&.value_before_type_cast

            # If model.<attribute> is nil, but model.<attribute>_before_type_cast is not nil,
            # that means the application failed to cast the value to the appropriate type in
            # order to complete the attribute assignment. This means the original value
            # is invalid.
            did_type_cast_fail = value.nil? && raw_value.present?
            if did_type_cast_fail
              errors.add(name, :invalid_date)
            end
          end
        end
      end
    end
  end
end
