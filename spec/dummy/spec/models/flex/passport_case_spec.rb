require 'rails_helper'

module Flex
  RSpec.describe PassportCase, type: :model do
    let(:test_case) { described_class.new }

    describe 'after create' do
      it 'initializes the business process' do
        test_case.save!

        expect(test_case.status).to eq('open')
      end
    end
  end
end
