require 'rails_helper'

RSpec.describe Flex::Task, type: :model do
  let(:task) { described_class.new }

  describe 'status attribute' do
    it 'does not allow status to be modified directly' do
      expect { task.status = :completed }.to raise_error(NoMethodError)
    end
  end

  describe '#assign' do
    let(:user) { User.create! }

    it 'assigns the task to the given user' do
      assignee_id = rand(1..1000)

      task.assign(assignee_id)

      expect(task.assignee_id).to eq(assignee_id)
    end
  end

  describe '#unassign' do
    let(:user) { User.create!(assignee_id: rand(1..1000)) }

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
end
