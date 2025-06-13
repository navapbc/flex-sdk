module Flex
  module Attributes
    # ArrayAttribute provides a DSL for defining attributes representing arrays
    # of value objects.
    #
    # @example Defining an array of addresses
    #   class Company < ApplicationRecord
    #     include Flex::Attributes
    #
    #     flex_attribute :office_locations, [:address]
    #   end
    #
    #   company = Company.new
    #   company.office_locations = [
    #     Flex::Address.new("123 Main St", nil, "Boston", "MA", "02108"),
    #     Flex::Address.new("456 Oak Ave", "Suite 4", "San Francisco", "CA", "94107")
    #   ]
    #
    # Key features:
    # - Stores arrays of value objects in a single jsonb column
    # - Automatic serialization and deserialization of array items
    # - Built-in validation of array items
    # - Support for various Flex value object types
    #
    module ArrayAttribute
      extend ActiveSupport::Concern

      # Custom type for handling arrays of value objects in ActiveRecord attributes
      #
      # @api private
      # @example Internal usage by array_attribute
      #   attribute :addresses, ArrayType.new("Flex::Address")
      #
      class ArrayType < ActiveModel::Type::Value
        # @return [String] The fully qualified class name of the array items
        attr_reader :item_class_name

        # Creates a new ArrayType for a specific value object class
        #
        # @param [String] item_class_name The fully qualified class name of items in the array
        # @example
        #   ArrayType.new("Flex::Address")
        def initialize(item_class_name)
          @item_class_name = item_class_name
        end

        def cast(value)
          Array(value)
        end

        def serialize(value)
          value.to_json
        end

        def deserialize(value)
          return [] if value.nil?
          JSON.parse(value).map do |item_hash|
            @item_class_name.constantize.from_hash(item_hash)
          end
        end
      end

      class_methods do
        # Defines an attribute representing an array of value objects.
        #
        # @param [Symbol] name The base name for the attribute
        # @param [Hash] options Options for the attribute
        # @return [void]
        # @param [Object] item_type
        def array_attribute(name, item_type, options = {})
          item_class_name = "Flex::#{item_type.to_s.camelize}"
          attribute name, ArrayType.new(item_class_name), default: []
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
