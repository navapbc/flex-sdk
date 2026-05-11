# frozen_string_literal: true

class AuditLogsController < StaffController
  include Pundit::Authorization

  def index
    @audit_lines = policy_scope(Strata::AuditLine).latest_first.limit(100)
  end

  protected

  # The dummy app has no Devise / authentication wiring; pick a user so the
  # Pundit scope has something to filter against. Production hosts replace
  # this with their real `current_user` implementation.
  def current_user
    User.first || User.create!(first_name: "Demo", last_name: "Staff")
  end
end
