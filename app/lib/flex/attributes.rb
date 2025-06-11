module Flex
  # Attributes is a module that extends ActiveRecord with custom attribute types.
  # It provides a consistent interface for defining specialized attributes like
  # memorable dates, names, addresses, tax IDs, and money amounts.
  #
  # This module should be included in models that need these custom attribute types.
  # See app/lib/flex/attributes/ folder for the list of all available flex attributes.
  #
  # @example Including Attributes in a model
  #   class MyModel < ApplicationRecord
  #     include Flex::Attributes
  #
  #     flex_attribute :birth_date, :memorable_date
  #     flex_attribute :applicant_name, :name
  #     flex_attribute :salary, :money
  #   end
  #
  module Attributes
    extend ActiveSupport::Concern
    include Flex::Attributes::AddressAttribute
    include Flex::Attributes::ArrayAttribute
    include Flex::Attributes::DateRangeAttribute
    include Flex::Attributes::MemorableDateAttribute
    include Flex::Attributes::MoneyAttribute
    include Flex::Attributes::NameAttribute
    include Flex::Attributes::TaxIdAttribute
    include Flex::Attributes::USDateAttribute
    include Flex::Attributes::YearQuarterAttribute

    class_methods do
      # Defines a custom attribute with the specified type.
      #
      # @param [Symbol] name The name of the attribute
      # @param [Symbol] type The type of attribute (:address, :date_range, :memorable_date, :money, :name, :tax_id, :us_date, :year_quarter)
      # @param [Hash] options Options for the attribute
      # @raise [ArgumentError] If an unsupported attribute type is provided
      # @return [void]
      def flex_attribute(name, type, options = {})
        case type
        when :address
          address_attribute name, options
        when :array
          array_attribute name, options
        when :date_range
          date_range_attribute name, options
        when :memorable_date
          memorable_date_attribute name, options
        when :money
          money_attribute name, options
        when :name
          name_attribute name, options
        when :tax_id
          tax_id_attribute name, options
        when :us_date
          us_date_attribute name, options
        when :year_quarter
          year_quarter_attribute name, options
        else
          raise ArgumentError, "Unsupported attribute type: #{type}"
        end
      end
    end
  end
end
