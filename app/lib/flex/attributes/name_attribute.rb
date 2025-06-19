module Flex
  module Attributes
    # NameAttribute provides functionality for handling name fields with first, middle, and last components.
    # It uses the Flex::Name value object for storage and manipulation.
    #
    # This module is automatically included when using Flex::Attributes.
    #
    # @example Using the name attribute
    #   class Person < ApplicationRecord
    #     include Flex::Attributes
    #
    #     flex_attribute :name, :name
    #   end
    #
    #   person = Person.new
    #   person.name = Flex::Name.new("John", "A", "Doe")
    #   puts person.name.first  # => "John"
    #
    module NameAttribute
      extend ActiveSupport::Concern

      class_methods do
        # Defines a name attribute with first, middle, and last components.
        #
        # @param [Symbol] name The base name for the attribute
        # @param [Hash] options Options for the attribute
        # @return [void]
        def name_attribute(name, options = {})
          # Define the base attribute with its subfields
          attribute "#{name}_first", :string
          attribute "#{name}_middle", :string
          attribute "#{name}_last", :string

          # Define the getter method
          define_method(name) do
            first = send("#{name}_first")
            middle = send("#{name}_middle")
            last = send("#{name}_last")
            Flex::Name.new(first:, middle:, last:)
          end

          # Define the setter method
          define_method("#{name}=") do |value|
            case value
            when Flex::Name
              send("#{name}_first=", value.first)
              send("#{name}_middle=", value.middle)
              send("#{name}_last=", value.last)
            when Hash
              send("#{name}_first=", value[:first])
              send("#{name}_middle=", value[:middle])
              send("#{name}_last=", value[:last])
            end
          end
        end
      end
    end
  end
end
