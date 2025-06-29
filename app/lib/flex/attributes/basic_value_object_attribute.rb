module Flex
  module Attributes
    module BasicValueObjectAttribute
      extend ActiveSupport::Concern
      include Validations

      class_methods do
        # Defines an attribute associated with a subclass of
        # Flex::ValueObject
        #
        # @param [Symbol] name The base name for the attribute
        # @param [Class] value_class the subclass of Flex::ValueObject
        # @param [Hash] options Options for the attribute
        # @return [void]
        # @param [Object] nested_attribute_types
        def basic_value_object_attribute(name, value_class, nested_attribute_types, options = {})
          # Define the base attribute with its subfields
          nested_attribute_types.each do |nested_attribute_name, nested_attribute_type|
            flex_attribute "#{name}_#{nested_attribute_name}", nested_attribute_type
          end

          # Define the getter method
          define_method(name) do
            value_hash = nested_attribute_types.keys.map do |nested_attribute_name|
              [ nested_attribute_name, send("#{name}_#{nested_attribute_name}") ]
            end.to_h
            value_class.new(value_hash)
          end

          # Define the setter method
          define_method(:"#{name}=") do |value|
            case value
            when value_class
              nested_attribute_types.keys.each do |nested_attribute_name|
                send("#{name}_#{nested_attribute_name}=", value.send(nested_attribute_name))
              end
            when Hash
              nested_attribute_types.keys.each do |nested_attribute_name|
                send("#{name}_#{nested_attribute_name}=", value[nested_attribute_name.to_sym] || value[nested_attribute_name.to_s])
              end
            end
          end

          flex_validates_nested(name)
        end
      end
    end
  end
end
