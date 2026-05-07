# frozen_string_literal: true

module Strata
  # AuditLine is an immutable record of something that happened.
  #
  # Columns:
  # - `action` (string, required) — short event name, e.g. `"case.approved"`.
  # - `subject_type` / `subject_id` (polymorphic, optional) — the record the
  #   event is about.
  # - `actor_type` / `actor_id` (polymorphic, optional) — who did it.
  # - `data` (jsonb, defaults to `{}`) — free-form caller-supplied payload.
  # - `created_at` (datetime) — when the line was recorded. There is no
  #   `updated_at`; lines are immutable.
  #
  # Lines are typically created via {Strata::AuditLog.record} (block form, wrapped
  # in a DB transaction) or {Strata::AuditLog.write!} (single-line form). Once
  # persisted, lines are read-only — updates and destroys raise
  # ActiveRecord::ReadOnlyRecord.
  #
  # @example Querying audit history for a record
  #   Strata::AuditLine.for_subject(case_record).latest_first
  class AuditLine < ApplicationRecord
    self.table_name = "strata_audit_lines"

    belongs_to :subject, polymorphic: true, optional: true
    belongs_to :actor,   polymorphic: true, optional: true

    validates :action, presence: true

    scope :for_subject, ->(subject) { where(subject: subject) }
    scope :by_actor,    ->(actor)   { where(actor: actor) }
    scope :with_action, ->(action)  { where(action: action.to_s) }
    scope :latest_first, -> { order(created_at: :desc) }

    def readonly?
      persisted?
    end
  end
end
