# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Strata::TaskService::Database do
  subject(:service) { described_class.new }

  let(:test_case) { TestCase.create! }
  let(:task_class) { Class.new(Strata::Task) }

  before do
    stub_const("DatabaseTestTask", task_class)
  end

  describe '#create_task' do
    it 'creates a task associated with the given case' do
      task = service.create_task(DatabaseTestTask, test_case)

      expect(task).to be_a(DatabaseTestTask)
      expect(task).to be_a(Strata::Task)
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
        expect { service.create_task(nil, test_case) }.to raise_error(ArgumentError, /`task_class` must be a Strata::Task or a subclass of Strata::Task/)
      end
    end

    context 'when given task class is not a subclass of Strata::Task' do
      it 'raises an error' do
        expect { service.create_task(String, test_case) }.to raise_error(ArgumentError, /`task_class` must be a Strata::Task or a subclass of Strata::Task/)
      end
    end

    context 'when given case is nil' do
      it 'raises an error' do
        expect { service.create_task(Strata::Task, nil) }.to raise_error(ArgumentError, /`kase` must be a subclass of Strata::Case/)
      end
    end
  end
end
