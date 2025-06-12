module Flex
  module Attributes
    # DateRangeAttribute provides a DSL for defining date range attributes in form models.
    # It uses Ruby's native Range class with composed_of to map start and end date columns
    # to a single range attribute.
    #
    # @example Adding a date range attribute to a form model
    #   class MyForm < Flex::ApplicationForm
    #     include Flex::Attributes::DateRangeAttribute
    #     date_range_attribute :employment_period
    #   end
    #
    # Key features:
    # - Uses Ruby's native Range class
    # - Maps start/end columns to Range#begin and Range#end
    # - Validates that start date <= end date
    # - Handles hash input conversion
    #
    module DateRangeAttribute
      extend ActiveSupport::Concern

      class_methods do
        # Defines a date range attribute with start and end components.
        #
        # @param [Symbol] name The base name for the attribute
        # @param [Hash] options Options for the attribute
        # @return [void]
        def date_range_attribute(name, options = {})
          # Define individual columns for start and end dates
          flex_attribute "#{name}_start", :us_date
          flex_attribute "#{name}_end", :us_date

          validates_date "#{name}_start", allow_blank: true
          validates_date "#{name}_end", allow_blank: true

          # Define the getter method
          define_method(name) do
            start_date = send("#{name}_start")
            end_date = send("#{name}_end")
            start_date || end_date ? DateRange.new(start_date, end_date) : nil
          end

          # Define the setter method
          define_method("#{name}=") do |value|
            case value
            when DateRange
              send("#{name}_start=", value.start)
              send("#{name}_end=", value.end)
            when Hash
              send("#{name}_start=", value[:start] || value["start"])
              send("#{name}_end=", value[:end] || value["end"])
            end
          end

          validate :"validate_#{name}"

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
