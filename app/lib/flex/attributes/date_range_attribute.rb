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
          attribute "#{name}_start", :date
          attribute "#{name}_end", :date

          # Set up composed_of mapping to Range
          composed_of name,
                      class_name: "Range",
                      mapping: [
                        [ "#{name}_start", "begin" ],
                        [ "#{name}_end", "end" ]
                      ],
                      converter: ->(value) {
                        case value
                        when Hash
                          start_date = value[:start] || value["start"]
                          end_date = value[:end] || value["end"]
                          if start_date || end_date
                            Range.new(start_date, end_date)
                          else
                            nil
                          end
                        when String
                          # Optional: Add string parsing logic if needed
                          nil
                        when nil
                          nil
                        else
                          nil
                        end
                      },
                      constructor: ->(start_date, end_date) {
                        if start_date || end_date
                          Range.new(start_date, end_date)
                        else
                          nil
                        end
                      },
                      allow_nil: true

          # Add validation for date range
          validate :"validate_#{name}_range"

          # Create a validation method that checks if start <= end
          define_method "validate_#{name}_range" do
            start_date = send("#{name}_start")
            end_date = send("#{name}_end")

            if start_date.present? && end_date.present? && start_date > end_date
              errors.add(name, :invalid_date_range, message: "start date must be before or equal to end date")
            end
          end
        end
      end
    end
  end
end
