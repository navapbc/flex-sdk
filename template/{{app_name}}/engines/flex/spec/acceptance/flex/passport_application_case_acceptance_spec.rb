require 'rails_helper'

module Flex
  RSpec.describe PassportApplicationForm, type: :model do
    let(:test_form) { described_class.new }

    it "creates a passport case upon starting a passport application form and properly progresses through steps" do
      # create new application
      test_form.save!

      # check case created
      kase = PassportCase.find(test_form.case_id)
      expect(kase).not_to be_nil
      expect(kase.business_process_current_step).to eq ("collect_application_info")

      # submit application
      test_form.first_name = "John"
      test_form.last_name = "Doe"
      test_form.date_of_birth = Date.new(1990, 1, 1)
      test_form.save!
      test_form.submit_application
      kase.reload
      expect(kase.business_process_current_step).to eq ("verify_identity")

      # verify identity (simulate action that an adjudicator takes)
      EventsManager.publish("identity_verified", { case_id: kase.id })
      kase.reload
      expect(kase.business_process_current_step).to eq ("review_passport_photo")

      # approve passport photo
      EventsManager.publish("passport_photo_approved", { case_id: kase.id })
      kase.reload
      expect(kase.business_process_current_step).to eq ("notify_user_passport_approved")

      # notify user
      EventsManager.publish("notification_completed", { case_id: kase.id })
      kase.reload
      expect(kase.business_process_current_step).to eq ("end")

      # check case status
      kase.reload
      expect(kase.status).to eq ("closed")
    end
  end
end
