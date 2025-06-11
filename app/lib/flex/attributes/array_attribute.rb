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

      class ArrayType < ActiveModel::Type::Value
        def cast(value)
          Array(value)
        end

        def serialize(value)
          value.to_json
        end

        def deserialize(value)
          return [] if value.nil?
          JSON.parse(value)
        end
      end

      class_methods do
        # Defines an attribute representing an array of value objects.
        #
        # @param [Symbol] name The base name for the attribute
        # @param [Hash] options Options for the attribute
        # @return [void]
        def array_attribute(name, item_type, options = {})
          attribute name, ArrayType.new, default: []
          validate :"validate_#{name}"

          # Create a validation method that validates each of the value objects
          define_method "validate_#{name}" do
            items = send(name)
            errors.add(name, :invalid_array) if items.any? do |item|
              if item.respond_to?(:invalid?)
                item.invalid?
              else
                # TODO(https://linear.app/nava-platform/issue/TSS-147/handle-validation-of-native-ruby-objects-in-array-class)
                # for cases where the item is a native Ruby type rather than an
                # ActiveModel (for example :memorable_date, :tax_id,
                # :date_range, etc.) the validation logic isn't on the class
                # itself, so we can't call `invalid?` directly. In this case we
                # should refactor the validation logic to be used both here and
                # in the value object attribute class.
                false
              end
            end
          end
        end
      end
    end
  end
end
