class Task < ApplicationRecord
  self.table_name = "flex_sdk_tasks"
  belongs_to :business_process, class_name: "BusinessProcess"

  class FindEmploymentRecordTask < Task
  end

  class CheckLeaveBalanceTask < Task
  end
end