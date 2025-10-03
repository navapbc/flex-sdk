# frozen_string_literal: true

module Strata
  module Attributes
    # MoneyAttribute provides a DSL for defining money attributes in form models.
    # It creates an integer field with validation and formatting capabilities for
    # US dollar amounts stored as cents.
    #
    # @example Adding a money attribute to a form model
    #   class MyForm < Strata::ApplicationForm
    #     include Strata::Attributes
    #
    #     strata_attribute :salary, :money
    #   end
    #
    # Key features:
    # - Custom ActiveRecord type for money handling
    # - Automatic conversion between dollars and cents
    # - Integration with Strata::Money for arithmetic operations
    #
    module MoneyAttribute
      extend ActiveSupport::Concern

      def self.attribute_type
        :single_column_value_object
      end



      # A custom ActiveRecord type that allows storing money amounts.
      # It uses the Strata::Money value object for storage and arithmetic operations.
      class MoneyType < ActiveModel::Type::Integer
        def cast(value)
          return nil if value.nil?

          return value if value.is_a?(Strata::Money)

          case value
          when Integer
            Strata::Money.new(cents: value)
          when Hash
            hash = value.with_indifferent_access
            if hash.key?(:dollar_amount) || hash.key?("dollar_amount")
              dollar_value = hash[:dollar_amount] || hash["dollar_amount"]
              return nil if dollar_value.blank?
              Strata::Money.new(cents: (dollar_value.to_f * 100).round)
            else
              nil
            end
          else
            nil
          end
        end

        def serialize(value)
          return nil if value.nil?
          return value.cents if value.is_a?(Strata::Money)
          value
        end

        def deserialize(value)
          return nil if value.nil?
          Strata::Money.new(cents: value)
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
