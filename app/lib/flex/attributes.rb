module Flex
  # Attributes is a module that extends ActiveRecord with custom attribute types.
  # It provides a consistent interface for defining specialized attributes like
  # memorable dates, names, addresses, and tax IDs.
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
  #   end
  #
  module Attributes
    extend ActiveSupport::Concern
    include Flex::Attributes::AddressAttribute
    include Flex::Attributes::MemorableDateAttribute
    include Flex::Attributes::NameAttribute
    include Flex::Attributes::TaxIdAttribute

    class_methods do
      # Defines a custom attribute with the specified type.
      #
      # @param [Symbol] name The name of the attribute
      # @param [Symbol] type The type of attribute (:memorable_date, :name, :address, :tax_id)
      # @param [Hash] options Options for the attribute
      # @raise [ArgumentError] If an unsupported attribute type is provided
      # @return [void]
      def flex_attribute(name, type, options = {})
        case type
        when :memorable_date
          memorable_date_attribute name, options
        when :name
          name_attribute name, options
        when :address
          address_attribute name, options
        when :tax_id
          tax_id_attribute name, options
        else
          raise ArgumentError, "Unsupported attribute type: #{type}"
        end
      end
    end
  end
end
