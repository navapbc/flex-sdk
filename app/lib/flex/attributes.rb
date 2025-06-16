module Flex
  # Attributes is a module that extends ActiveRecord with custom attribute types.
  # It provides a consistent interface for defining specialized attributes like
  # memorable dates, names, addresses, tax IDs, and money amounts.
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
  #     flex_attribute :salary, :money
  #   end
  #
  module Attributes
    extend ActiveSupport::Concern
    include Flex::Attributes::AddressAttribute
    include Flex::Attributes::ArrayAttribute
    include Flex::Attributes::MemorableDateAttribute
    include Flex::Attributes::MoneyAttribute
    include Flex::Attributes::NameAttribute
    include Flex::Attributes::RangeAttribute
    include Flex::Attributes::TaxIdAttribute
    include Flex::Attributes::USDateAttribute
    include Flex::Attributes::YearQuarterAttribute

    # Helper method. Given a type, return the corresponding class in the Flex module.
    # If the class is not found in the Flex module, it will try to find it
    # in the global namespace.
    def self.resolve_class(type)
      begin
        "Flex::#{type.to_s.camelize}".constantize
      rescue NameError
        type.to_s.camelize.constantize
      end
    end

    class_methods do
      # Defines a custom attribute with the specified type.
      #
      # @param [Symbol] name The name of the attribute
      # @param [Symbol] type The type of attribute (:address, :memorable_date, :money, :name, :tax_id, :us_date, :year_quarter)
      # @param [Hash] options Options for the attribute. This includes:
      #   - `:array` (Boolean): If true, the attribute will be an array of the specified type
      #   - `:range` (Boolean): If true, the attribute will be a Flex::ValueRange of the specified type
      # @raise [ArgumentError] If an unsupported attribute type is provided
      # @return [void]
      def flex_attribute(name, type, options = {})
        is_array = options.delete(:array) || false
        is_range = options.delete(:range) || false

        if is_array
          array_attribute name, type, options
          return
        end

        if is_range
          range_attribute name, type, options
          return
        end

        case type
        when :address
          address_attribute name, options
        when :memorable_date
          memorable_date_attribute name, options
        when :money
          money_attribute name, options
        when :name
          name_attribute name, options
        when :tax_id
          tax_id_attribute name, options
        when :us_date
          us_date_attribute name, options
        when :year_quarter
          year_quarter_attribute name, options
        when :year_quarter_range
          year_quarter_range_attribute name, options
        else
          raise ArgumentError, "Unsupported attribute type: #{type}"
        end
      end

      def flex_validates_nested(name)
        validate :"validate_nested_#{name}"

        # Adds a validator for an attribute that represents a value object.
        # Calls valid? on the object and adds any errors to the root model's
        # errors. Any errors on :base will be added to the root model under
        # the attribute name, while errors on other attributes will be prefixed
        # with the attribute name. For example, if the attribute is :date_range,
        # and the value object has an error on :start, it will be added as
        # "date_range_start" in the root model's errors.
        #
        # @param [Symbol] name The base name for the attribute
        # @return [void]
        define_method "validate_nested_#{name}" do
          range = send(name)
          if range && range.invalid?
            range.errors.each do |error|
              if error.attribute == :base
                errors.add(name, error.type)
              else
                errors.add("#{name}_#{attribute}", error.type)
              end
            end
          end
        end
      end
    end
  end
end
