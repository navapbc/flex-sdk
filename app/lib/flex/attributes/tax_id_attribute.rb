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
          validates name, format: { with: Flex::TaxId::TAX_ID_FORMAT, message: :invalid_tax_id }
        end
      end
    end
  end
end
