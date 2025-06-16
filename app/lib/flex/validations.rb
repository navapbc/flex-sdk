module Flex
  module Validations
    extend ActiveSupport::Concern

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
          if value && value.invalid?
            value.errors.each do |error|
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
