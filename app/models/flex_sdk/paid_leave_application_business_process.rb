module FlexSdk
  class PaidLeaveApplicationBusinessProcess < BusinessProcess
    # belongs_to :paid_leave_application
    def run
      tasks.create!(type: "FindEmploymentRecordTask")
    end
  end
end