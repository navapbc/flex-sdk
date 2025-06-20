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

      class_methods do
        def address_attribute(name, options = {})
          # Define the base attribute with its subfields
          attribute "#{name}_street_line_1", :string
          attribute "#{name}_street_line_2", :string
          attribute "#{name}_city", :string
          attribute "#{name}_state", :string
          attribute "#{name}_zip_code", :string

          # Define the getter method
          define_method(name) do
            street_line_1 = send("#{name}_street_line_1")
            street_line_2 = send("#{name}_street_line_2")
            city = send("#{name}_city")
            state = send("#{name}_state")
            zip_code = send("#{name}_zip_code")
            Flex::Address.new(street_line_1:, street_line_2:, city:, state:, zip_code:)
          end

          # Define the setter method
          define_method("#{name}=") do |value|
            case value
            when Flex::Address
              send("#{name}_street_line_1=", value.street_line_1)
              send("#{name}_street_line_2=", value.street_line_2)
              send("#{name}_city=", value.city)
              send("#{name}_state=", value.state)
              send("#{name}_zip_code=", value.zip_code)
            when Hash
              send("#{name}_street_line_1=", value[:street_line_1])
              send("#{name}_street_line_2=", value[:street_line_2])
              send("#{name}_city=", value[:city])
              send("#{name}_state=", value[:state])
              send("#{name}_zip_code=", value[:zip_code])
            end
          end
        end
      end
    end
  end
end
