module Strata
  module Attributes
    # YearMonthAttribute provides functionality for handling year and month fields.
    # It uses the Strata::YearMonth value object for storage and manipulation.
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
    #   report.reporting_period = Strata::YearMonth.new(2023, 6)
    #   puts report.reporting_period.year     # => 2023
    #   puts report.reporting_period.month    # => 6
    #
    module YearMonthAttribute
      extend ActiveSupport::Concern
      include Flex::Validations

      def self.attribute_type
        :single_column_value_object
      end

      # Custom ActiveModel type for handling YearMonth values.
      # Supports casting from hashes, strings, and YearMonth objects.
      # Serializes to string format "YYYY-MM" for database storage.
      class YearMonthType < ActiveModel::Type::Value
        def cast(value)
          case value
          when nil
            nil
          when Strata::YearMonth
            value
          when Hash
            hash = value.with_indifferent_access
            year = hash[:year]
            month = hash[:month]
            Strata::YearMonth.new(year:, month:)
          when String
            parts = value.split("-")
            return nil if parts.length < 2
            year = parts[0]
            month = parts[1]
            Strata::YearMonth.new(year:, month:)
          else
            nil
          end
        end

        def serialize(value)
          return nil if value.nil?
          value.to_s
        end

        def deserialize(value)
          return nil if value.nil?
          cast(value)
        end
      end

      class_methods do
        # Defines a year month attribute with year and month components.
        #
        # @param [Symbol] name The base name for the attribute
        # @param [Hash] options Options for the attribute
        # @return [void]
        def year_month_attribute(name, options = {})
          attribute name, YearMonthType.new
          flex_validates_nested(name)
          flex_validates_type_casted_attribute(name, :invalid_year_month)
        end
      end
    end
  end
end
