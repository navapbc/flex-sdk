require 'rails_helper'

module Flex
  RSpec.describe PassportCase, type: :model do
    let(:test_case) { described_class.new }

    before do
      allow(Flex::PassportApplicationBusinessProcessManager.instance).to receive(:business_process)
        .and_return(double("BusinessProcess", execute: true))
    end

    describe 'status attribute' do
      it 'defaults to open' do
        expect(test_case.status).to eq('open')
      end

      it 'can be closed using the close method' do
        test_case.close
        expect(test_case.status).to eq('closed')
      end

      it 'can be reopened using the reopen method' do
        test_case.close
        test_case.reopen
        expect(test_case.status).to eq('open')
      end

      it 'cannot be directly modified from outside the class' do
        expect { test_case.status = :closed }.to raise_error(NoMethodError)
      end
    end
  end
end
