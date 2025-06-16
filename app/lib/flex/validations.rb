module Flex
  # Validations is a module that provides nested validation support for value objects.
  # It extends ActiveModel::Validations to handle validation of nested attributes in a
  # consistent way, propagating errors from nested objects to the parent model with
  # appropriate attribute name prefixing.
  #
  # This module should be included in models that need to validate nested value objects.
  # It provides the flex_validates_nested class method for defining these validations.
  # It is automatically included in the Flex::Attributes module.
  #
  # @example Including Validations in a model and validating a nested date range
  #   class MyModel < ApplicationRecord
  #     include Flex::Validations
  #
  #     flex_validates_nested :period
  #   end
  #
  module Validations
    extend ActiveSupport::Concern
    include ActiveModel::Validations

    class_methods do
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
          value = send(name)
          if value && value.respond_to?(:invalid?) && value.invalid?
            value.errors.each do |error|
              if error.attribute == :base
                errors.add(name, error.type)
              else
                errors.add("#{name}_#{error.attribute}", error.type, **error.options)
              end
            end
          end
        end
      end
    end
  end
end
