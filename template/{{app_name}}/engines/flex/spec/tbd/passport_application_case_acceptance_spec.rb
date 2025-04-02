require 'rails_helper'
require_relative '../dummy/app/models/flex/business_processes/passport_application_business_process'

module Flex
  RSpec.describe PassportApplicationForm, type: :model do
    let(:test_form) { described_class.new }

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
