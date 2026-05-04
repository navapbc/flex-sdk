# frozen_string_literal: true

module Strata
  # AuditLine is an immutable record of something that happened. Each line carries
  # an action string, an optional polymorphic subject (the record the event is
  # about), an optional polymorphic actor (who did it), and a free-form jsonb
  # `data` payload for caller-supplied details.
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
