module Flex
  module Attributes
    # MoneyAttribute provides a DSL for defining money attributes in form models.
    # It creates an integer field with validation and formatting capabilities for
    # US dollar amounts stored as cents.
    #
    # This module includes a custom ActiveRecord type that integrates with the
    # Flex::Money value object for storage and formatting.
    #
    # @example Adding a money attribute to a form model
    #   class MyForm < Flex::ApplicationForm
    #     include Flex::Attributes::MoneyAttribute
    #     money_attribute :salary
    #   end
    #
    # Key features:
    # - Custom ActiveRecord type for money handling
    # - Automatic conversion between dollars and cents
    # - Integration with Flex::Money for arithmetic operations
    #
    module MoneyAttribute
      extend ActiveSupport::Concern

      # A custom ActiveRecord type that allows storing money amounts.
      # It uses the Flex::Money value object for storage and arithmetic operations.
      class MoneyType < ActiveRecord::Type::Integer
        # Override cast to ensure proper Money format
        def cast(value)
          return nil if value.nil?

          # If it's already a Money object, return it
          return value if value.is_a?(Flex::Money)

          # Handle different input types
          case value
          when Hash
            # Support hash input with dollar_amount or cents_amount keys
            if value.key?(:dollar_amount) || value.key?("dollar_amount")
              dollar_value = value[:dollar_amount] || value["dollar_amount"]
              Flex::Money.new((dollar_value.to_f * 100).round)
            elsif value.key?(:cents_amount) || value.key?("cents_amount")
              cents_value = value[:cents_amount] || value["cents_amount"]
              Flex::Money.new(cents_value.to_i)
            else
              nil
            end
          when Float
            # Assume float input is in dollars, convert to cents
            Flex::Money.new((value * 100).round)
          else
            # Otherwise create a new Money object (assumes cents)
            Flex::Money.new(value)
          end
        end

        def type
          :money
        end
      end

      class_methods do
        def money_attribute(name, options = {})
          attribute name, MoneyType.new
        end
      end
    end
  end
end
