# frozen_string_literal: true

module Strata
  # Per-handler work state for a durable {Event}.
  #
  # Columns:
  # - `id` (UUID): delivery identifier.
  # - `strata_event_id` (UUID): event being delivered.
  # - `handler` (String): registered handler class name.
  # - `target_type` / `target_id` (String): optional polymorphic target.
  # - `status` (Integer): delivery outcome, exposed through the status enum.
  # - `attempts` (Integer): number of delivery attempts.
  # - `next_attempt_at` (DateTime): earliest time a failed delivery may retry.
  # - `last_error` (Text): most recent handler error.
  # - `created_at` / `updated_at` (DateTime): lifecycle timestamps.
  class EventDelivery < ApplicationRecord
    self.table_name = "strata_event_deliveries"

    belongs_to :event,
      class_name: "Strata::Event",
      foreign_key: :strata_event_id,
      inverse_of: :deliveries

    enum :status, {
      pending: 0,
      handled: 1,
      no_transition: 2,
      no_target: 3,
      failed: 4,
      dead_letter: 5
    }

    validates :handler, presence: true
    validates :attempts, numericality: { greater_than_or_equal_to: 0 }

    scope :terminal, -> { where(status: [ :handled, :no_transition, :no_target, :dead_letter ]) }
    scope :non_terminal, -> { where(status: [ :pending, :failed ]) }
    scope :ready_for_retry, ->(now = Time.current) {
      non_terminal.where("next_attempt_at IS NULL OR next_attempt_at <= ?", now)
    }

    def terminal?
      handled? || no_transition? || no_target? || dead_letter?
    end
  end
end
