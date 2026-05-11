# frozen_string_literal: true

module Strata
  # Marker module host apps include in non-ActiveRecord actor classes so
  # `Strata::AuditLine` can persist and round-trip them via the polymorphic
  # `actor_type` column. No methods are required on the including class.
  #
  # @example
  #   class Api::Client
  #     include Strata::VirtualActor
  #   end
  #
  #   Strata::AuditLog.write!(action: "system.synced", actor: Api::Client.new)
  module VirtualActor
    # Immutable value object returned by `Strata::AuditLine#actor` when the
    # underlying row stores a virtual actor (actor_id IS NULL, actor_type
    # names a class that includes Strata::VirtualActor).
    #
    # Identity is the class name only — per-instance state on the original
    # virtual actor is not persisted.
    class Instance < Strata::ValueObject
      attribute :actor_type, :string

      def display_name
        actor_type.to_s.demodulize.underscore.humanize
      end
    end
  end
end
