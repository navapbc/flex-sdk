# frozen_string_literal: true

module Strata
  # Validations is a module that provides nested validation support for value objects.
  # It extends ActiveModel::Validations to handle validation of nested attributes in a
  # consistent way, propagating errors from nested objects to the parent model with
  # appropriate attribute name prefixing.
  #
  # This module should be included in models that need to validate nested value objects.
  # It provides the strata_validates_nested class method for defining these validations.
  # It is automatically included in the Strata::Attributes module.
  #
  # @example Including Validations in a model and validating a nested date range
  #   class MyModel < ApplicationRecord
  #     include Strata::Validations
  #
  #     strata_validates_nested :period
  #   end
  #
  module Validations
    extend ActiveSupport::Concern
    include ActiveModel::Validations

    class_methods do
      def strata_validates_nested(name)
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
          return if value.nil? || (value.respond_to?(:blank?) && value.blank?)

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

      def strata_validates_type_casted_attribute(name, error_type)
        validate :"validate_type_casted_attribute_#{name}"

        define_method "validate_type_casted_attribute_#{name}" do
          value = send(name)
          raw_value = @attributes[name.to_s]&.value_before_type_cast

          # If model.<attribute> is nil, but model.<attribute>_before_type_cast is not nil,
          # that means the application failed to cast the value to the appropriate type in
          # order to complete the attribute assignment. This means the original value
          # is invalid.
          did_type_cast_fail = value.nil? && raw_value.present?
          if did_type_cast_fail
            errors.add(name, error_type)
          end
        end
      end
    end
  end
end
