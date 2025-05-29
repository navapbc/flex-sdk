require 'rails_helper'

class DatabaseTestTask < Flex::Task
end

RSpec.describe Flex::TaskService::Database do
  subject(:service) { described_class.new }

  let(:test_case) { TestCase.create! }


  describe '#create_task' do
    it 'creates a task associated with the given case' do
      task = service.create_task(DatabaseTestTask, test_case)

      expect(task).to be_a(DatabaseTestTask)
      expect(task).to be_a(Flex::Task)
      expect(task).to be_persisted
      expect(task.case_id).to eq(test_case.id)
    end

    it 'creates task with default pending status' do
      task = service.create_task(DatabaseTestTask, test_case)

      expect(task.status).to eq('pending')
    end

    it 'creates task with no assignee by default' do
      task = service.create_task(DatabaseTestTask, test_case)

      expect(task.assignee_id).to be_nil
    end

    context 'when given task class is nil' do
      it 'raises an error' do
        expect { service.create_task(nil, test_case) }.to raise_error(ArgumentError, /`task_class` must be a Flex::Task or a subclass of Flex::Task/)
      end
    end

    context 'when given task class is not a subclass of Flex::Task' do
      it 'raises an error' do
        expect { service.create_task(String, test_case) }.to raise_error(ArgumentError, /`task_class` must be a Flex::Task or a subclass of Flex::Task/)
      end
    end

    context 'when given case is nil' do
      it 'raises an error' do
        expect { service.create_task(Flex::Task, nil) }.to raise_error(ArgumentError, /`kase` must be a subclass of Flex::Case/)
      end
    end
  end
end
