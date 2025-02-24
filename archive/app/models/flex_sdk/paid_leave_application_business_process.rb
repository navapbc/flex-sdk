module FlexSdk
  class PaidLeaveApplicationBusinessProcess < BusinessProcess
    has_many :tasks, class_name: "FlexSdk::Task", foreign_key: "flex_sdk_business_process_id"

    def run
      tasks.create!(type: "FlexSdk::FindEmploymentRecordTask")
    end
  end
end
