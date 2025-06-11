module Flex
  module Attributes
    # ArrayAttribute provides a DSL for defining attributes representing arrays
    # of value objects.
    #
    # @example TODO
    #
    # Key features:
    # - TODO
    #
    module ArrayAttribute
      extend ActiveSupport::Concern

      class_methods do
        # Defines an attribute representing an array of value objects.
        #
        # @param [Symbol] name The base name for the attribute
        # @param [Hash] options Options for the attribute
        # @return [void]
        def array_attribute(name, options = {})
          attribute name, :json, default: []
          validate :"validate_#{name}"

          # Create a validation method that validates each of the value objects
          define_method "validate_#{name}" do
            items = send(name)
            errors.add(name, :invalid_array) if items.any?(&:invalid?)
          end
        end
      end
    end
  end
end
