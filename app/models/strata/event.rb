# frozen_string_literal: true

module Strata
  # A durable domain event written in the same transaction as the change that
  # caused it. Handler-specific work is tracked by {EventDelivery} records.
  class Event < ApplicationRecord
    self.table_name = "strata_events"

    has_many :deliveries,
      class_name: "Strata::EventDelivery",
      foreign_key: :strata_event_id,
      inverse_of: :event,
      dependent: :destroy

    validates :name, :occurred_at, presence: true

    scope :undispatched, -> { where(dispatched_at: nil) }
    scope :occurred_before, ->(cutoff) { where(occurred_at: ...cutoff) }

    # The compatibility event shape consumed by business-process handlers.
    def message
      { name: name, payload: payload.deep_symbolize_keys }
    end
  end
end
