# frozen_string_literal: true

module Strata
  # Auditable adds an audit_lines association to any model, exposing the
  # immutable history of actions recorded against it via {Strata::AuditLog}.
  #
  # Audit lines deliberately do NOT cascade-destroy with the host record:
  # an audit trail should outlive its subject so the history of "this record
  # was deleted" remains queryable.
  #
  # @example
  #   class Case < ApplicationRecord
  #     include Strata::Auditable
  #   end
  #
  #   case_record.audit_lines.latest_first
  module Auditable
    extend ActiveSupport::Concern

    included do
      has_many :audit_lines, as: :subject, class_name: "Strata::AuditLine"
    end
  end
end
