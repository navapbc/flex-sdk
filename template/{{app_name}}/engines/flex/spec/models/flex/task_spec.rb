require 'rails_helper'

RSpec.describe Flex::Task, type: :model do
  let(:kase) { TestCase.create! }
  let(:task) { described_class.new(case_id: kase.id) }

  describe 'status attribute' do
    it 'does not allow status to be modified directly' do
      expect { task.status = :completed }.to raise_error(NoMethodError)
    end
  end

  describe '#assign' do
    it 'assigns the task to the given user' do
      assignee_id = rand(1..1000).to_s

      task.assign(assignee_id)

      expect(task.assignee_id).to eq(assignee_id)
    end
  end

  describe '#unassign' do
    it 'removes the assignee from the task' do
      task.unassign

      expect(task.assignee_id).to be_nil
    end
  end

  describe '#mark_completed' do
    it 'marks the task as completed' do
      task.mark_completed

      expect(task.status).to eq('completed')
    end
  end
  
  describe '#mark_pending' do
    it 'marks the task as pending' do
      task.mark_completed

      task.mark_pending

      expect(task.status).to eq('pending')
    end
  end
end
