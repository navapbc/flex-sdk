# frozen_string_literal: true

class AuditLogsController < StaffController
  def index
    @audit_lines = Strata::AuditLine.latest_first.limit(100)
  end
end
