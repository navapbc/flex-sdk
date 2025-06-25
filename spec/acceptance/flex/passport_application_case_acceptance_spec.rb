require 'rails_helper'

module Flex
  RSpec.describe PassportBusinessProcess, type: :model do
    let(:test_form) { build(:passport_application_form) }

    before do
      described_class.start_listening_for_events
    end

    it "creates a passport case upon starting a passport application form and properly progresses through steps" do
      # create new application
      test_form.save!

      # check case created and open with correct current step
      kase = PassportCase.find_by_application_form_id(test_form.id)
      business_process_instance = described_class.for_case(kase.id).first!
      expect(kase).not_to be_nil
      expect(kase.status).to eq ("open")
      expect(business_process_instance.current_step).to eq ("submit_application")

      # submit application
      test_form.name = Flex::Name.new(first: "John", last: "Doe")
      test_form.date_of_birth = Date.new(1990, 1, 1)
      test_form.save!
      test_form.submit_application
      business_process_instance.reload
      expect(business_process_instance.current_step).to eq ("verify_identity")

      # verify identity (simulate action that an adjudicator takes)
      Flex::EventManager.publish("identity_verified", { case_id: kase.id })
      business_process_instance.reload
      expect(business_process_instance.current_step).to eq ("review_passport_photo")

      # approve passport photo
      Flex::EventManager.publish("passport_photo_approved", { case_id: kase.id })
      business_process_instance.reload
      expect(business_process_instance.current_step).to eq ("notify_user_passport_approved")

      # notify user
      Flex::EventManager.publish("notification_completed", { case_id: kase.id })
      expect(described_class.for_case(kase.id).exists?).to be_falsey

      # check case status
      kase.reload
      expect(kase).to be_closed
    end
  end
end
