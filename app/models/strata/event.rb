# frozen_string_literal: true

module Strata
  # A durable domain event written in the same transaction as the change that
  # caused it. Handler-specific work is tracked by {EventDelivery} records.
  class Event < ApplicationRecord
    self.table_name = "strata_events"

    CONTENT_ATTRIBUTES = %w[id name payload correlation_id causation_id occurred_at created_at].freeze

    has_many :deliveries,
      class_name: "Strata::EventDelivery",
      foreign_key: :strata_event_id,
      inverse_of: :event,
      dependent: :destroy

    validates :name, :occurred_at, presence: true

    before_update :prevent_content_changes
    before_destroy :prevent_destruction, prepend: true

    scope :dispatched, -> { where.not(dispatched_at: nil) }
    scope :undispatched, -> { where(dispatched_at: nil) }
    scope :ready_for_routing, ->(now = Time.current) {
      undispatched
        .where("next_attempt_at IS NULL OR next_attempt_at <= ?", now)
        .order(Arel.sql("next_attempt_at ASC NULLS FIRST"), :occurred_at, :id)
    }
    scope :occurred_before, ->(cutoff) { where(occurred_at: ...cutoff) }

    # The compatibility event shape consumed by business-process handlers.
    def message
      { name: name, payload: payload.deep_symbolize_keys }
    end

    def delete
      prevent_destruction
    end

    private

    def prevent_content_changes
      changed_content = CONTENT_ATTRIBUTES & changes_to_save.keys
      if changed_content.empty? && will_save_change_to_updated_at?
        operational_change = will_save_change_to_dispatched_at? || will_save_change_to_next_attempt_at?
        changed_content << "updated_at" unless operational_change
      end
      return if changed_content.empty?

      raise ActiveRecord::ReadOnlyRecord,
        "Persisted Strata::Event content is immutable (changed: #{changed_content.join(', ')})"
    end

    def prevent_destruction
      raise ActiveRecord::ReadOnlyRecord,
        "Persisted Strata::Event records may only be removed by the audited event pruner"
    end
  end
end
