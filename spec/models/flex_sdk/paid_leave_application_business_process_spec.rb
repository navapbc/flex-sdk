require "rails_helper"

RSpec.describe FlexSdk::PaidLeaveApplicationBusinessProcess, type: :model do
  describe "Business Process Flow" do
    it "creagtes a business process and its first task" do
      application = FlexSdk::PaidLeaveApplication.create(
        applicant_id: 1,
        leave_reason: "bonding",
        applicant_first_name: "Princess",
        applicant_last_name: "Carolyn"
      )

      application.submit
      
      process = FlexSdk::PaidLeaveApplicationBusinessProcess.find_by(application_id: applicant.id)
      expect(process).to be_present

      task = process.tasks.find_by(type: "FindEmploymentRecordTask")
      expect(task_.to be_present)
    end
  end
end