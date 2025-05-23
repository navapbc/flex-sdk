require 'rails_helper'

RSpec.describe Flex::TaskService do
  let(:test_case) { TestCase.create! }

  describe '.get' do
    before do
      described_class.set(nil)
    end

    it 'returns the default Database adapter when no service is set' do
      service = described_class.get
      expect(service).to be_a(Flex::TaskService::Database)
    end

    it 'returns the same service instance on subsequent calls' do
      first_service = described_class.get
      second_service = described_class.get
      expect(first_service).to eq(second_service)
    end
  end

  describe '.set' do
    let(:salesforce_service) do
      Class.new(Flex::TaskService::Base) do
        def create_task(kase)
        end
      end.new
    end

    it 'sets the task service implementation' do
      described_class.set(salesforce_service)
      expect(described_class.get).to eq(salesforce_service)
    end

    it 'raises ArgumentError when service is not a TaskService::Base' do
      invalid_service = Class.new.new
      expect { described_class.set(invalid_service) }.to raise_error(
        ArgumentError,
        'Service must be a subclass of TaskService::Base'
      )
    end
  end
end
