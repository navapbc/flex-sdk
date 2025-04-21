require 'rails_helper'

class TestCase < Flex::Case
  # A simple test case to test the Case abstract class functionality
end

RSpec.describe TestCase, type: :model do
  let(:test_case) { described_class.new }

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
