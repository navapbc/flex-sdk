require 'rails_helper'

module Flex
  RSpec.describe PassportCase, type: :model do
    let(:test_case) { described_class.new }
    let(:mock_business_process) { instance_double(BusinessProcess, execute: true) }

    before do
      allow(PassportApplicationBusinessProcessManager.instance)
        .to receive(:business_process)
        .and_return(mock_business_process)
    end

    describe 'after create' do
      it 'initializes the business process' do
        test_case.save!

        expect(PassportApplicationBusinessProcessManager.instance.business_process)
          .to have_received(:execute)
          .with(case_id: test_case.id)
      end
    end
  end
end
