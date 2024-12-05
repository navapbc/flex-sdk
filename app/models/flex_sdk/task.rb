module FlexSdk
  class Task < ApplicationRecord
    self.table_name = "flex_sdk_tasks"
    belongs_to :flex_sdk_business_process, class_name: "BusinessProcess", foreign_key: "flex_sdk_business_process_id"
end

class FindEmploymentRecordTask < Task
  end

  class CheckLeaveBalanceTask < Task
  end
end

FlexSdk::Task