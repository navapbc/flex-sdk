module Flex
  module Attributes
    # RangeAttribute provides a DSL for defining attributes representing ranges
    # of values using ValueRange objects.
    #
    # @example Defining a date range
    #   class Enrollment < ApplicationRecord
    #     include Flex::Attributes
    #
    #     flex_attribute :period, :us_date, range: true
    #   end
    #
    #   enrollment = Enrollment.new
    #   enrollment.period = Flex::DateRange.new(Date.new(2023, 1, 1), Date.new(2023, 12, 31))
    #
    # Key features:
    # - Stores ranges in a single jsonb column
    # - Automatic serialization and deserialization of ValueRange objects
    # - Built-in validation
    #
    module RangeAttribute
      extend ActiveSupport::Concern
      include Flex::Validations

      # Module-level attribute type identifier
      def self.attribute_type
        :multi_column_value_object
      end

      class_methods do
        # Defines an attribute representing a range using ValueRange.
        #
        # @param [Symbol] name The base name for the attribute
        # @param [Hash] options Options for the attribute
        # @return [void]
        # @param [Object] value_type
        def range_attribute(name, value_type, options = {})
          value_class = Flex::Attributes.resolve_class(value_type)

          basic_value_object_attribute(name, ValueRange[value_class], {
            "start" => value_type,
            "end" => value_type
          }, options)

          alias_method :"set_basic_value_object_#{name}=", :"#{name}="

          define_method(:"#{name}=") do |value|
            case value
            when Range
              send("#{name}_start=", value.begin)
              send("#{name}_end=", value.end)
            else
              send("set_basic_value_object_#{name}=", value)
            end
          end

          flex_validates_nested(name)
        end
      end
    end
  end
end
