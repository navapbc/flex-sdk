module Flex
  module Attributes
    module TaxIdAttribute
      extend ActiveSupport::Concern

      # A custom ActiveRecord type that allows storing a Tax ID (such as SSN).
      # It behaves the same as the default String type, but provides validation
      # and formatting for Tax IDs in the format XXX-XX-XXXX.
      class TaxId < ActiveRecord::Type::String
        # Regular expression for validating Tax ID format (SSN format)
        TAX_ID_FORMAT = /\A\d{3}-\d{2}-\d{4}\z/

        # Override cast to ensure proper Tax ID format
        def cast(value)
          return nil if value.nil?

          # If it's already a properly formatted Tax ID, return it
          return value if value.is_a?(String) && value.match?(TAX_ID_FORMAT)

          # If it's a string but not properly formatted, try to format it
          if value.is_a?(String)
            # Remove any non-digit characters
            digits = value.gsub(/\D/, "")

            # If we have exactly 9 digits, format as Tax ID
            if digits.length == 9
              return "#{digits[0..2]}-#{digits[3..4]}-#{digits[5..8]}"
            end
          end

          # Return the original value if we couldn't format it
          value
        end

        def type
          :tax_id
        end
      end

      class_methods do
        def tax_id_attribute(name, options = {})
          attribute name, TaxId.new

          validate :"validate_#{name}"

          if options[:presence]
            validates name, presence: true
          end

          # Create a validation method that checks if the value is a valid Tax ID
          define_method "validate_#{name}" do
            value = send(name)

            # Skip validation if the value is nil and not required
            return if value.nil? && !options[:presence]

            # Validate Tax ID format if value is present
            if value.present? && !value.match?(TaxId::TAX_ID_FORMAT)
              errors.add(name, :invalid_tax_id, message: "is not a valid Tax ID format (XXX-XX-XXXX)")
            end
          end
        end
      end
    end
  end
end
