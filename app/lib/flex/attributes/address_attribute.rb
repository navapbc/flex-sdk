module Flex
  module Attributes
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

          # Set up composed_of mapping
          composed_of name,
                      class_name: "Flex::Address",
                      mapping: [
                        [ "#{name}_street_line_1", "street_line_1" ],
                        [ "#{name}_street_line_2", "street_line_2" ],
                        [ "#{name}_city", "city" ],
                        [ "#{name}_state", "state" ],
                        [ "#{name}_zip_code", "zip_code" ]
                      ],
                      converter: ->(value) {
                        case value
                        when Hash
                          Flex::Address.new(
                            value[:street_line_1],
                            value[:street_line_2],
                            value[:city],
                            value[:state],
                            value[:zip_code]
                          )
                        else
                          nil
                        end
                      }
        end
      end
    end
  end
end
