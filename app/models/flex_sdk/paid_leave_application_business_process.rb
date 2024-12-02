module FlexSdk
  class PaidLeaveApplicationBusinessProcess < BusinessProcess
    def run
      tasks.create!(type: "FindEmploymentRecordTask")
    end
  end
end