# frozen_string_literal: true

module Strata
  # Reference Pundit policy for Strata::AuditLine in the dummy app.
  #
  # Audit lines are polymorphic: each line points at some `subject_type` /
  # `subject_id`. A staff user should only see audit lines whose subject they
  # already have access to. Without this policy, the controller would expose
  # the entire audit table — including history for records the user has no
  # business reading.
  #
  # This policy filters Strata::AuditLine by joining each known subject type to
  # its host-side policy scope. System events (rows with `subject_id = nil`)
  # are visible to any logged-in user, since they describe global activity
  # rather than a specific record.
  #
  # Production hosts should adapt this policy to enumerate the auditable
  # subject types in their own application.
  class AuditLinePolicy < ::ApplicationPolicy
    def index?
      user.present?
    end

    class Scope < ::ApplicationPolicy::Scope
      # Map of subject_type → ActiveRecord scope of ids the user is allowed to
      # see. Hosts extend this when they add new auditable models.
      def visible_subject_ids_by_type
        {
          "TestApplicationForm" => ::TestApplicationForm.where(user_id: user.id).select(:id)
        }
      end

      def resolve
        filters = visible_subject_ids_by_type.map do |type, ids|
          scope.where(subject_type: type, subject_id: ids)
        end

        # System events have no subject; they are visible to any logged-in user.
        filters << scope.where(subject_id: nil)

        filters.reduce { |combined, next_filter| combined.or(next_filter) }
      end
    end
  end
end
