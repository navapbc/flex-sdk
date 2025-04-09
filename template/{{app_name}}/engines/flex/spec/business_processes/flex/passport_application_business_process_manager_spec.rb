require 'rails_helper'

module Flex
  RSpec.describe PassportApplicationBusinessProcessManager do
    let(:manager) { described_class.instance }
    let(:business_process) { manager.business_process }

    describe '#business_process' do
      it 'is a business process' do
        expect(business_process).to be_a(BusinessProcess)
        expect(manager).to be(described_class.instance)
        expect(business_process).to be(described_class.instance.business_process)
      end

      it 'is always the same instance' do
        expect(manager.business_process).to be(business_process)
        expect(described_class.instance.business_process).to be(business_process)
      end
    end
  end
end
