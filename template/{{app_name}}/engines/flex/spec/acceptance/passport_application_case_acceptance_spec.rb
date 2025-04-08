require 'rails_helper'

module Flex
  RSpec.describe PassportApplicationForm, type: :model do
    let(:test_form) { described_class.new }

    it "happy path from Loren's example" do
      # create new application
      app = PassportApplicationForm.new
      app.save!

      # check case created
      kase = PassportCase.find(app.case_id)
      expect(kase).not_to be nil
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
      kase.reload
      expect(kase.business_process_current_step).to eq ("end")
      expect(kase.status).to eq ("closed")
    end

    describe "when creating a form" do
      it "should create an associated case" do

      end
    end

    # describe 'when submitting a form' do
    #   it 'should not create a case if ' do
    #     test_form.first_name = 'John'
    #     test_form.last_name = 'Doe'
    #     test_form.date_of_birth = Date.new(1990, 1, 1)
    #     test_form.save!

    #     expect(test_form.valid?).to be true

    #     kase = test_form.passport_case
    #     expect(kase).not_to be_nil

    #     business_process = kase.business_process
    #     expect(business_process).not_to be_nil
    #     expect(business_process.name).to eq('Passport Application Process')

    #     business_process.execute(kase)
    #     expect(business_process.current_step).to eq('collect_user_info')

    #     test_form.submit_application
    #     expect(test_form.status).to eq('submitted')

    #     business_process.execute(kase)
    #     expect(business_process.current_step).to eq('collect_user_info')
    #   end
    # end

    # describe 'on create' do
    #   it 'creates a new passport application case' do
    #     test_form.save!

    #     expect(test_form.passport_case).not_to be_nil
    #   end

    #   it 'creates a new passport application business process' do
    #     expect(test_form.valid?).to be true
    #     test_form.save!
    #     test_form.reload
    #     test_form.passport_case.save!
    #     test_form.passport_case.reload
    #     expect(test_form.passport_case.valid?).to be true

    #     expect(test_form.passport_case.business_processes).not_to be_nil
    #     expect(test_form.passport_case.business_processes.first).not_to be_nil
    #   end
    # end
  end
end
