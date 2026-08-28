# frozen_string_literal: true

module Strata
  # Per-handler work state for a durable {Event}.
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
