# frozen_string_literal: true

module Strata
  module Attributes
    # Adds a derived user-facing ID attribute backed by an integer sequence column.
    module UserFacingIdAttribute
      extend ActiveSupport::Concern

      def self.attribute_type
        :derived_single_column
      end

      # Casts formatted user-facing IDs to their backing integer sequence values.
      class UserFacingIdSequenceType < ActiveModel::Type::Integer
        def initialize(prefix:, key:)
          @prefix = prefix
          @key = key
          super()
        end

        def cast(value)
          return nil if value.nil?
          return value if value.is_a?(Integer)

          Strata::UserFacingId::Codec.decode(value, prefix: @prefix, key: @key)
        rescue Strata::UserFacingId::Error
          nil
        end

        # Route serialize through cast so query strings like "T-Y01-B33-N91" are decoded
        # to the integer sequence; the inherited Integer#serialize would coerce them to 0.
        def serialize(value)
          cast(value)
        end
      end

      class_methods do
        def user_facing_id_attribute(name, options = {})
          prefix = options.fetch(:prefix)
          sequence_column = options.fetch(:sequence_column, :"#{name}_sequence")
          key = options.fetch(:key, Strata::UserFacingId::Codec::DEFAULT_KEY)

          Strata::UserFacingId::Codec.normalize_prefix(prefix)

          attribute sequence_column, UserFacingIdSequenceType.new(prefix:, key:)
          alias_attribute name, sequence_column

          define_method(name) do
            sequence_value = public_send(sequence_column)
            next nil if sequence_value.nil?

            Strata::UserFacingId::Codec.encode(sequence_value, prefix:, key:)
          end

          # Raise on bad string assignment (loud, debuggable) while leaving the
          # type's permissive cast in place so query paths still return nil.
          define_method("#{name}=") do |value|
            coerced =
              if value.is_a?(String) && value.strip.present?
                Strata::UserFacingId::Codec.decode(value, prefix:, key:)
              else
                value
              end

            public_send("#{sequence_column}=", coerced)
          end
        end
      end
    end
  end
end
