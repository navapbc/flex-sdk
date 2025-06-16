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

      class_methods do
        # Defines an attribute representing a range using ValueRange.
        #
        # @param [Symbol] name The base name for the attribute
        # @param [Hash] options Options for the attribute
        # @return [void]
        # @param [Object] value_type
        def range_attribute(name, value_type, options = {})
          value_class = Flex::Attributes.resolve_class(value_type)

          # Define individual columns for start and end dates
          flex_attribute :"#{name}_start", value_type
          flex_attribute :"#{name}_end", value_type

          # Define the getter method
          define_method(name) do
            start_value = send("#{name}_start")
            end_value = send("#{name}_end")
            return nil unless start_value.is_a?(value_class) || start_value.nil?
            return nil unless end_value.is_a?(value_class) || end_value.nil?
            start_value || end_value ? ValueRange[value_class].new(start_value, end_value) : nil
          end

          # Define the setter method
          define_method("#{name}=") do |value|
            case value
            when ValueRange[value_class]
              send("#{name}_start=", value.start)
              send("#{name}_end=", value.end)
            when Range
              send("#{name}_start=", value.begin)
              send("#{name}_end=", value.end)
            when Hash
              send("#{name}_start=", value[:start] || value["start"])
              send("#{name}_end=", value[:end] || value["end"])
            end
          end

          flex_validates_nested(name)
        end
      end
    end
  end
end
