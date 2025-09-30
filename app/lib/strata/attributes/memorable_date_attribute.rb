module Strata
  module Attributes
    # MemorableDateAttribute provides a DSL for defining date attributes in form models
    # that can be entered as separate year, month, and day fields.
    #
    # @example Adding a memorable date attribute to a form model
    #   class MyForm < Flex::ApplicationForm
    #     include Strata::Attributes
    #
    #     strata_attribute :birth_date, :memorable_date
    #   end
    #
    # Key features:
    # - Custom ActiveRecord type for date handling
    # - Automatic validation of date values
    # - Integration with form builder for date input fields
    #
    module MemorableDateAttribute
      extend ActiveSupport::Concern

      def self.attribute_type
        :single_column_value_object
      end

      # A custom ActiveRecord type that allows storing a date. It behaviors the same
      # as the default Date type, but it allows setting the attribute using a hash
      # with keys :year, :month, and :day. This is meant to be used in conjunction
      # with the memorable_date method in the Flex form builder
      class MemorableDate < ActiveModel::Type::Date
        # Override cast to allow setting the date via a Hash with keys :year, :month, :day.
        def cast(value)
          return super(value) unless value.is_a?(Hash)

          begin
            # Use strptime since Date.new is too lenient, allowing things like negative months and years
            value = Date.strptime("#{value[:year]}-#{value[:month]}-#{value[:day]}", "%Y-%m-%d")
          rescue ArgumentError
            nil
          end
        end

        def type
          :date_from_hash
        end
      end

      class_methods do
        def memorable_date_attribute(name, options)
          attribute name, MemorableDate.new

          validate :"validate_#{name}"

          # Create a validation method that checks if the value is a valid date
          define_method "validate_#{name}" do
            value = send(name)
            raw_value = read_attribute_before_type_cast(name)

            # If model.<attribute> is nil, but model.<attribute>_before_type_cast is not nil,
            # that means the application failed to cast the value to the appropriate type in
            # order to complete the attribute assignment. This means the original value
            # is invalid.
            did_type_cast_fail = value.nil? && raw_value.present?
            if did_type_cast_fail
              errors.add(name, :invalid_date)
            end
          end
        end
      end
    end
  end
end
