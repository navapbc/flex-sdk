module Flex
  module Attributes
    module TaxIdAttribute
      extend ActiveSupport::Concern

      # A custom ActiveRecord type that allows storing a Tax ID (such as SSN).
      # It uses the Flex::TaxId value object for storage and formatting.
      class TaxIdType < ActiveRecord::Type::String
        # Override cast to ensure proper Tax ID format
        def cast(value)
          return nil if value.nil?

          # If it's already a TaxId, return it
          return value if value.is_a?(Flex::TaxId)

          # Otherwise create a new TaxId object
          Flex::TaxId.new(value)
        end

        def type
          :tax_id
        end
      end

      class_methods do
        def tax_id_attribute(name, options = {})
          attribute name, TaxIdType.new

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
            if value.present? && !value.formatted.match?(Flex::TaxId::TAX_ID_FORMAT)
              errors.add(name, :invalid_tax_id, message: "id is not a valid Tax ID format (XXX-XX-XXXX)")
            end
          end
        end
      end
    end
  end
end
