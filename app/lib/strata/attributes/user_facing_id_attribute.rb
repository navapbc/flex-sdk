# frozen_string_literal: true

module Strata
  module Attributes
    # Adds a derived user-facing ID attribute backed by an integer sequence column.
    module UserFacingIdAttribute
      extend ActiveSupport::Concern

      def self.attribute_type
        :derived_single_column
      end

      class_methods do
        def user_facing_id_attribute(name, options = {})
          prefix = options.fetch(:prefix)
          sequence_column = options.fetch(:sequence_column, :"#{name}_sequence")
          key = options.fetch(:key, Strata::UserFacingId::Codec::DEFAULT_KEY)

          Strata::UserFacingId::Codec.normalize_prefix(prefix)

          define_method(name) do
            sequence_value = public_send(sequence_column)
            next nil if sequence_value.nil?

            Strata::UserFacingId::Codec.encode(sequence_value, prefix:, key:)
          end

          user_facing_id_scope = lambda do |value|
            sequence_value = Strata::UserFacingId::Codec.decode(value, prefix:, key:)
            where(sequence_column => sequence_value)
          rescue Strata::UserFacingId::Error
            none
          end
          scope :"with_#{name}", user_facing_id_scope

          define_singleton_method(:"find_by_#{name}") do |value|
            sequence_value = Strata::UserFacingId::Codec.decode(value, prefix:, key:)
            find_by(sequence_column => sequence_value)
          rescue Strata::UserFacingId::Error
            nil
          end

          define_singleton_method(:"find_by_#{name}!") do |value|
            sequence_value = Strata::UserFacingId::Codec.decode(value, prefix:, key:)
            find_by!(sequence_column => sequence_value)
          rescue Strata::UserFacingId::ParityError
            raise ActiveRecord::RecordNotFound, "Couldn't find #{name} with '#{value}'"
          end
        end
      end
    end
  end
end
