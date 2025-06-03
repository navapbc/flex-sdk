module Flex
  module Attributes
    # YearQuarterAttribute provides functionality for handling year and quarter fields.
    # It uses the Flex::YearQuarter value object for storage and manipulation.
    #
    # This module is automatically included when using Flex::Attributes.
    #
    # @example Using the year quarter attribute
    #   class Report < ApplicationRecord
    #     include Flex::Attributes
    #
    #     flex_attribute :reporting_period, :year_quarter
    #   end
    #
    #   report = Report.new
    #   report.reporting_period = Flex::YearQuarter.new(2023, 2)
    #   puts report.reporting_period.year     # => 2023
    #   puts report.reporting_period.quarter  # => 2
    #
    module YearQuarterAttribute
      extend ActiveSupport::Concern

      class_methods do
        # Defines a year quarter attribute with year and quarter components.
        #
        # @param [Symbol] name The base name for the attribute
        # @param [Hash] options Options for the attribute
        # @return [void]
        def year_quarter_attribute(name, options = {})
          # Define the base attribute with its subfields
          attribute "#{name}_year", :integer
          attribute "#{name}_quarter", :integer

          # Add validation for quarter values
          validates "#{name}_quarter", inclusion: { in: [1, 2, 3, 4] }, allow_nil: true

          # Set up composed_of mapping
          composed_of name,
                      class_name: "Flex::YearQuarter",
                      mapping: [
                        [ "#{name}_year", "year" ],
                        [ "#{name}_quarter", "quarter" ]
                      ],
                      converter: ->(value) {
                        case value
                        when Hash
                          Flex::YearQuarter.new(value[:year], value[:quarter])
                        else
                          nil
                        end
                      }
        end
      end
    end
  end
end
