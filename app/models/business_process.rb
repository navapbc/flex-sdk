class BusinessProcess < ApplicationRecord
  self.table_name = "flex_sdk_business_processes"

  has_many :tasks
  belongs_to :application, class_name: "FlexSdk::PaidLeaveApplication"

  def run
    tasks.create!(type: "FindEmploymentRecordTask")
  end
end
