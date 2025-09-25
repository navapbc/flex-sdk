module Flex
  module Attributes
    # ArrayAttribute provides a DSL for defining attributes representing arrays
    # of value objects.
    #
    # @example Defining an array of addresses
    #   class Company < ApplicationRecord
    #     include Flex::Attributes
    #
    #     flex_attribute :office_locations, :address, array: true
    #   end
    #
    #   company = Company.new
    #   company.office_locations = [
    #     Strata::Address.new(street_line_1: "123 Main St", street_line_2: nil, city: "Boston", state: "MA", zip_code: "02108"),
    #     Strata::Address.new(street_line_1: "456 Oak Ave", street_line_2: "Suite 4", city: "San Francisco", state: "CA", zip_code: "94107")
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

      def self.attribute_type
        :array
      end

      # Custom type for handling arrays of value objects in ActiveRecord attributes
      #
      # @api private
      # @example Internal usage by array_attribute
      #   attribute :addresses, ArrayType.new("Strata::Address")
      #
      class ArrayType < ActiveModel::Type::Value
        # @return [String] The fully qualified class name of the array items
        attr_reader :item_class

        # Creates a new ArrayType for a specific value object class
        #
        # @param [String] item_class The fully qualified class name of items in the array
        # @example
        #   ArrayType.new("Strata::Address")
        def initialize(item_class)
          @item_class = item_class
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
            item_class.new(item_hash)
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
          item_class = Flex::Attributes::ArrayAttribute.get_item_class(item_type)

          attribute name, ArrayType.new(item_class), default: []
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

      def self.get_item_class(item_type)
        if !item_type.is_a?(Array)
          return Flex::Attributes.resolve_class(item_type)
        end

        # Handle nested attributes that are arrays or ranges
        nested_type = item_type.first
        nested_options = item_type.last
        is_nested_type_an_array = nested_options.delete(:array) || false
        is_nested_type_a_range = nested_options.delete(:range) || false

        raise ArgumentError, "Arrays of arrays are not currently supported" if is_nested_type_an_array
        raise ArgumentError, "Expected range to be true for array item type when using syntax: `flex_attribute :name, [:type, range: true], array: true`" unless is_nested_type_a_range

        value_class = Flex::Attributes.resolve_class(nested_type)
        Strata::ValueRange[value_class]
      end
    end
  end
end
