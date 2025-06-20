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
      include Flex::Validations

      class_methods do
        # Defines a year quarter attribute with year and quarter components.
        #
        # @param [Symbol] name The base name for the attribute
        # @param [Hash] options Options for the attribute
        # @return [void]
        def year_quarter_attribute(name, options = {})
          # Define the base attribute with its subfields
          attribute :"#{name}_year", :integer
          attribute :"#{name}_quarter", :integer

          # Define the getter method
          define_method(name) do
            year = send("#{name}_year")
            quarter = send("#{name}_quarter")
            year || quarter ? Flex::YearQuarter.new(year:, quarter:) : nil
          end

          # Define the setter method
          define_method("#{name}=") do |value|
            case value
            when Flex::YearQuarter
              send("#{name}_year=", value.year)
              send("#{name}_quarter=", value.quarter)
            when Hash
              send("#{name}_year=", value[:year] || value["year"])
              send("#{name}_quarter=", value[:quarter] || value["quarter"])
            end
          end

          flex_validates_nested(name)
        end
      end
    end
  end
end
