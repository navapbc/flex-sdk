module Flex
  module Attributes
    # TaxIdAttribute provides a DSL for defining tax ID attributes in form models.
    # It creates a string field with validation and formatting capabilities for
    # tax identification numbers (e.g., SSNs).
    #
    # @example Adding a tax ID attribute to a form model
    #   class MyForm < Flex::ApplicationForm
    #     include Flex::Attributes
    #
    #     flex_attribute :ssn, :tax_id
    #   end
    #
    # Key features:
    # - Custom ActiveRecord type for tax ID handling
    # - Automatic validation of tax ID format
    # - Integration with Strata::TaxId for formatting
    #
    module TaxIdAttribute
      extend ActiveSupport::Concern

      def self.attribute_type
        :single_column_value_object
      end

      # A custom ActiveRecord type that allows storing a Tax ID (such as SSN).
      # It uses the Strata::TaxId value object for storage and formatting.
      class TaxIdType < ActiveModel::Type::String
        # Override cast to ensure proper Tax ID format
        def cast(value)
          return nil if value.nil?

          # If it's already a TaxId, return it
          return value if value.is_a?(Strata::TaxId)

          # Otherwise create a new TaxId object
          Strata::TaxId.new(value)
        end

        def type
          :tax_id
        end
      end

      class_methods do
        def tax_id_attribute(name, options = {})
          attribute name, TaxIdType.new
          validates name, format: { with: Strata::TaxId::TAX_ID_FORMAT_NO_DASHES, message: :invalid_tax_id }, allow_nil: true
        end
      end
    end
  end
end
