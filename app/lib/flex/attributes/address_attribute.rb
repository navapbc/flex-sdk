module Flex
  module Attributes
    # AddressAttribute provides a DSL for defining address attributes in form models.
    # It sets up a composed_of relationship with the Flex::Address value object
    # to map street_line_1, street_line_2, city, state, and zip_code fields
    # to a single address value object attribute.
    #
    # @example Adding an address attribute to a form model
    #   class MyForm < Flex::ApplicationForm
    #     include Flex::Attributes::AddressAttribute
    #     address_attribute :mailing_address
    #   end
    #
    # Key features:
    # - Creates individual fields for address components
    # - Sets up composed_of mapping to Flex::Address
    # - Handles conversion between form data and Address objects
    #
    module AddressAttribute
      extend ActiveSupport::Concern
      include BasicValueObjectAttribute

      def self.attribute_type
        :multi_column_value_object
      end

      class_methods do
        def address_attribute(name, options = {})
          basic_value_object_attribute(name, Flex::Address, {
            "street_line_1" => :string,
            "street_line_2" => :string,
            "city" => :string,
            "state" => :string,
            "zip_code" => :string
          }, options)
        end
      end
    end
  end
end
