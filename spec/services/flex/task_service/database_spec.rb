require 'rails_helper'

RSpec.describe Flex::TaskService::Database do
  subject(:service) { described_class.new }

  let(:test_case) { TestCase.create! }


  describe '#create_task' do
    it 'creates a task associated with the given case' do
      task = service.create_task(test_case)

      expect(task).to be_a(Flex::Task)
      expect(task).to be_persisted
      expect(task.case_id).to eq(test_case.id.to_s)
    end

    it 'creates task with default pending status' do
      task = service.create_task(test_case)

      expect(task.status).to eq('pending')
    end

    it 'creates task with no assignee by default' do
      task = service.create_task(test_case)

      expect(task.assignee_id).to be_nil
    end

    context 'when case is nil' do
      it 'raises an error' do
        expect { service.create_task(nil) }.to raise_error(ArgumentError, /Case can't be blank/)
      end
    end
  end
end
