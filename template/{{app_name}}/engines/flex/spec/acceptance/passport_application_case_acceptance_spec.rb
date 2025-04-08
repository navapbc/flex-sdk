require 'rails_helper'

module Flex
  RSpec.describe PassportApplicationForm, type: :model do
    let(:test_form) { described_class.new }

    it "happy path from Loren's example" do
      # create new application
      app = test_form
      app.save!

      # check case created
      kase = PassportCase.find(app.case_id)
      expect(kase).not_to be_nil
      expect(kase.business_process_current_step).to eq ("collect application info")

      # submit application
      app.first_name = "John"
      app.last_name = "Doe"
      app.date_of_birth = Date.new(1990, 1, 1)
      app.save!
      app.submit_application
      kase.reload
      expect(kase.business_process_current_step).to eq ("verify identity")

      # verify identity (simulate action that an adjudicator takes)
      kase.verify_identity
      expect(kase.business_process_current_step).to eq ("review passport photo")

      # approve application
      kase.approve
      expect(kase.business_process_current_step).to eq ("end")
      expect(kase.status).to eq ("closed")
    end
  end
end
