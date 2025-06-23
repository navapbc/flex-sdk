require 'rails_helper'

module Flex
  RSpec.describe PassportBusinessProcess, type: :model do
    let(:test_form) { build(:passport_application_form) }

    it "creates a passport case upon starting a passport application form and properly progresses through steps" do
      # create new application
      test_form.save!

      # check case created and open with correct current step
      kase = PassportCase.find_by_application_form_id(test_form.id)
      expect(kase).not_to be_nil
      expect(kase.status).to eq ("open")
      expect(kase.business_process_current_step).to eq ("submit_application")

      # submit application
      test_form.name = Flex::Name.new(first: "John", last: "Doe")
      test_form.date_of_birth = Date.new(1990, 1, 1)
      test_form.save!
      test_form.submit_application
      kase.reload
      expect(kase.business_process_current_step).to eq ("verify_identity")

      # verify identity (simulate action that an adjudicator takes)
      Flex::EventManager.publish("identity_verified", { case_id: kase.id })
      kase.reload
      expect(kase.business_process_current_step).to eq ("review_passport_photo")

      # approve passport photo
      Flex::EventManager.publish("passport_photo_approved", { case_id: kase.id })
      kase.reload
      expect(kase.business_process_current_step).to eq ("notify_user_passport_approved")

      # notify user
      Flex::EventManager.publish("notification_completed", { case_id: kase.id })
      kase.reload
      expect(kase.business_process_current_step).to eq ("end")

      # check case status
      expect(kase.status).to eq ("closed")
    end
  end
end
