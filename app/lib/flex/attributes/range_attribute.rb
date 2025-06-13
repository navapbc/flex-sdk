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

      # Custom type for handling ValueRange objects in ActiveRecord attributes
      #
      # @api private
      # @example Internal usage by range_attribute
      #   attribute :period, RangeType.new
      #
      class RangeType < ActiveModel::Type::Value
        # @return [String] The fully qualified class name of the array items
        attr_reader :value_class

        # Creates a new ArrayType for a specific value object class
        #
        # @param [String] value_class The fully qualified class name of items in the array
        # @example
        #   ArrayType.new("Flex::Address")
        def initialize(value_class)
          @value_class = value_class
        end

        def cast(value)
          case value
          when Flex::ValueRange[value_class]
            value
          when Hash
            Flex::ValueRange[value_class].new(value['start'], value['end'])
          else
            nil
          end
        end

        def serialize(value)
          return nil if value.nil?
          { 'start' => value.start, 'end' => value.end }.to_json
        end

        def deserialize(value)
          return nil if value.nil?
          data = JSON.parse(value)
          Flex::ValueRange.new(data['start'], data['end'])
        end
      end

      class_methods do
        # Defines an attribute representing a range using ValueRange.
        #
        # @param [Symbol] name The base name for the attribute
        # @param [Hash] options Options for the attribute
        # @return [void]
        def range_attribute(name, value_type, options = {})
          value_class = begin
                          "Flex::#{value_type.to_s.camelize}".constantize
                        rescue NameError
                          value_type.to_s.camelize.constantize
                        end

          # Define individual columns for start and end dates
          flex_attribute :"#{name}_start", value_type
          flex_attribute :"#{name}_end", value_type

          validate :"validate_#{name}_start"
          validate :"validate_#{name}_end"
          validate :"validate_#{name}"

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

          define_method "validate_#{name}_start" do
          end

          define_method "validate_#{name}_end" do
          end

          # TODO
          # This looks like it could be generalized into a "nested object" validator
          define_method "validate_#{name}" do
            range = send(name)
            if range && range.invalid?
              range.errors.each do |error|
                if error.attribute == :base
                  errors.add(name, error.type)
                else
                  errors.add("#{name}_#{attribute}", error.type)
                end
              end
            end
          end
        end
      end
    end
  end
end
