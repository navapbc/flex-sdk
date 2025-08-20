module Flex
  module Attributes
    # YearMonthAttribute provides functionality for handling year and month fields.
    # It uses the Flex::YearMonth value object for storage and manipulation.
    #
    # This module is automatically included when using Flex::Attributes.
    #
    # @example Using the year month attribute
    #   class Report < ApplicationRecord
    #     include Flex::Attributes
    #
    #     flex_attribute :reporting_period, :year_month
    #   end
    #
    #   report = Report.new
    #   report.reporting_period = Flex::YearMonth.new(2023, 6)
    #   puts report.reporting_period.year     # => 2023
    #   puts report.reporting_period.month    # => 6
    #
    module YearMonthAttribute
      extend ActiveSupport::Concern
      include BasicValueObjectAttribute

      class_methods do
        # Defines a year month attribute with year and month components.
        #
        # @param [Symbol] name The base name for the attribute
        # @param [Hash] options Options for the attribute
        # @return [void]
        def year_month_attribute(name, options = {})
          # Define the base attribute with its subfields
          attribute :"#{name}_year", :integer
          attribute :"#{name}_month", :integer
          basic_value_object_attribute(name, Flex::YearMonth, {
            "year" => :integer,
            "month" => :integer
          }, options)
        end
      end
    end
  end
end
