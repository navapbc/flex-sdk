# frozen_string_literal: true

module Strata
  # AuditLine is an immutable record of something that happened. Lines are
  # typically created via {Strata::AuditLog.record} (block form, wrapped in a
  # DB transaction) or {Strata::AuditLog.write!} (single-line form). Once
  # persisted, lines are read-only — updates and destroys raise
  # ActiveRecord::ReadOnlyRecord.
  #
  # @example Querying audit history for a record
  #   Strata::AuditLine.for_subject(case_record).latest_first
  class AuditLine < ApplicationRecord
    self.table_name = "strata_audit_lines"

    belongs_to :subject, polymorphic: true, optional: true
    belongs_to :actor,   polymorphic: true, optional: true

    attribute :action,     :string
    attribute :data,       :jsonb, default: {}
    attribute :created_at, :datetime

    validates :action, presence: true

    scope :for_subject,  ->(subject) { where(subject: subject) }
    scope :by_actor,     ->(actor)   { where(actor: actor) }
    scope :with_action,  ->(action)  { where(action: action.to_s) }
    scope :latest_first, -> { order(created_at: :desc) }

    def readonly?
      persisted?
    end
  end
end
