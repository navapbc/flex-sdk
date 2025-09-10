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
      include Validations

      # Module-level attribute type identifier
      def self.attribute_type
        :single_column_value_object
      end

      # Custom ActiveModel type for handling YearMonth values.
      # Supports casting from hashes, strings, and YearMonth objects.
      # Serializes to string format "YYYY-MM" for database storage.
      class YearMonthType < ActiveModel::Type::Value
        def cast(value)
          return nil if value.nil?
          return value if value.is_a?(Flex::YearMonth)

          case value
          when Hash
            hash = value.with_indifferent_access
            year = hash[:year]
            month = hash[:month]
            Flex::YearMonth.new(year: year, month: month)
          when String
            parts = value.split("-")
            return nil if parts.length < 2
            year = parts[0].to_i
            month = parts[1].to_i
            Flex::YearMonth.new(year: year, month: month)
          else
            nil
          end
        end

        def serialize(value)
          return nil if value.nil?
          return nil unless value.is_a?(Flex::YearMonth)
          "#{value.year}-#{value.month.to_s.rjust(2, '0')}"
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
          flex_validates_nested(name) if options.fetch(:validate, true)
        end
      end
    end
  end
end
