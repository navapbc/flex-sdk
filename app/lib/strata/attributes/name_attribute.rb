# frozen_string_literal: true

module Strata
  module Attributes
    # NameAttribute provides functionality for handling name fields with first, middle, and last components.
    # It uses the Strata::Name value object for storage and manipulation.
    #
    # This module is automatically included when using Strata::Attributes.
    #
    # @example Using the name attribute
    #   class Person < ApplicationRecord
    #     include Strata::Attributes
    #
    #     strata_attribute :name, :name
    #   end
    #
    #   person = Person.new
    #   person.name = Strata::Name.new("John", "A", "Doe")
    #   puts person.name.first  # => "John"
    #
    module NameAttribute
      extend ActiveSupport::Concern
      include BasicValueObjectAttribute

      def self.attribute_type
        :multi_column_value_object
      end

      class_methods do
        # Defines a name attribute with first, middle, and last components.
        #
        # @param [Symbol] name The base name for the attribute
        # @param [Hash] options Options for the attribute
        # @return [void]
        def name_attribute(name, options = {})
          basic_value_object_attribute(name, Strata::Name, {
            "first" => :string,
            "middle" => :string,
            "last" => :string
          }, options)
        end
      end
    end
  end
end
