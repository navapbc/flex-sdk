require 'rails_helper'
require_relative '../dummy/app/models/flex/business_processes/passport_application_business_process'
require_relative '../../app/models/concerns/step'

module Flex
  RSpec.describe PassportApplicationForm, type: :model do
    let(:test_form) { described_class.new }

    describe 'when starting a new form' do
      it 'happy path' do
        test_form.first_name = 'John'
        test_form.last_name = 'Doe'
        test_form.date_of_birth = Date.new(1990, 1, 1)
        test_form.save!

        expect(test_form.valid?).to be true

        kase = test_form.passport_case
        expect(kase).not_to be_nil

        business_process = kase.business_processes.first
        expect(business_process).not_to be_nil
        expect(business_process.name).to eq('Passport Application Process')

        business_process.execute(kase)
        expect(business_process.current_step).to eq('collect_user_info')

        test_form.submit_application
        expect(test_form.status).to eq('submitted')

        business_process.execute(kase)
        expect(business_process.current_step).to eq('collect_user_info')
      end
    end




    describe 'on create' do
      it 'creates a new passport application case' do
        test_form.save!

        expect(test_form.passport_case).not_to be_nil
      end

      it 'creates a new passport application business process' do
        expect(test_form.valid?).to be true
        test_form.save!
        test_form.reload
        test_form.passport_case.save!
        test_form.passport_case.reload
        expect(test_form.passport_case.valid?).to be true

        expect(test_form.passport_case.business_processes).not_to be_nil
        expect(test_form.passport_case.business_processes.first).not_to be_nil
      end
    end
  end
end
