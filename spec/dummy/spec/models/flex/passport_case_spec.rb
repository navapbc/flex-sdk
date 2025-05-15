require 'rails_helper'

module Flex
  RSpec.describe PassportCase, type: :model do
    let(:test_application_form) { PassportApplicationForm.create! }
    let(:test_case) { described_class.find_by(application_form_id: test_application_form.id) }

    describe 'after create' do
      it 'initializes the business process' do
        test_case.save!

        expect(test_case.status).to eq('open')
        expect(test_case.business_process_current_step).to eq('collect_application_info')
      end
    end
  end
end
