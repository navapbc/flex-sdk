module Flex
  module Attributes
    module NameAttribute
      extend ActiveSupport::Concern

      class_methods do
        def name_attribute(name, options = {})
          # Define the base attribute with its subfields
          attribute "#{name}_first", :string
          attribute "#{name}_middle", :string
          attribute "#{name}_last", :string

          # Set up composed_of mapping
          composed_of name,
                      class_name: "Flex::Name",
                      mapping: [
                        [ "#{name}_first", "first" ],
                        [ "#{name}_middle", "middle" ],
                        [ "#{name}_last", "last" ]
                      ],
                      converter: ->(value) {
                        case value
                        when Hash
                          Flex::Name.new(value[:first], value[:middle], value[:last])
                        else
                          nil
                        end
                      }
        end
      end
    end
  end
end
