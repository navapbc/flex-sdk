module Flex
  module Attributes
    # YearQuarterAttribute provides functionality for handling year and quarter fields.
    # It uses the Strata::YearQuarter value object for storage and manipulation.
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
    #   report.reporting_period = Strata::YearQuarter.new(2023, 2)
    #   puts report.reporting_period.year     # => 2023
    #   puts report.reporting_period.quarter  # => 2
    #
    module YearQuarterAttribute
      extend ActiveSupport::Concern
      include Validations

      def self.attribute_type
        :single_column_value_object
      end

      # Custom ActiveModel type for handling YearQuarter values.
      # Supports casting from hashes, strings, and YearQuarter objects.
      # Serializes to string format "YYYYQQ" for database storage.
      class YearQuarterType < ActiveModel::Type::Value
        def cast(value)
          case value
          when nil
            nil
          when Strata::YearQuarter
            value
          when Hash
            hash = value.with_indifferent_access
            year = hash[:year]
            quarter = hash[:quarter]
            Strata::YearQuarter.new(year:, quarter:)
          when String
            parts = value.split("Q")
            return nil if parts.length < 2
            year = parts[0]
            quarter = parts[1]
            Strata::YearQuarter.new(year:, quarter:)
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
        # Defines a year quarter attribute with year and quarter components.
        #
        # @param [Symbol] name The base name for the attribute
        # @param [Hash] options Options for the attribute
        # @return [void]
        def year_quarter_attribute(name, options = {})
          attribute name, YearQuarterType.new
          flex_validates_nested(name)
          flex_validates_type_casted_attribute(name, :invalid_year_quarter)
        end
      end
    end
  end
end
