# frozen_string_literal: true

module Strata
  # ValueObject is a base class for immutable objects that represent a set of attributes.
  # It includes ActiveModel modules for attribute handling, validations, and JSON serialization.
  # It includes a default equality comparison method that compares by value rather than by identity.
  # It also supports default serialization to JSON based on attributes.
  #
  # @example
  #   class Money < Strata::ValueObject
  #     attribute :amount, :integer
  #     attribute :currency, :string
  #   end
  #
  #   money = Money.new(amount: 100, currency: "USD")
  #
  # @!attribute [r] attributes
  #   @return [Hash] the attributes of the value object
  class ValueObject
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::AttributeAssignment
    include ActiveModel::Validations
    include ActiveModel::Serializers::JSON
    include Strata::Attributes
    include Strata::Validations

    def ==(other)
      return false if self.class != other.class

      attributes.each do |name, value|
        return false if public_send(name) != other.public_send(name)
      end
      true
    end

    def blank?
      attributes.values.all?(&:blank?)
    end

    def persisted?
      false
    end

    def present?
      !blank?
    end
  end
end
