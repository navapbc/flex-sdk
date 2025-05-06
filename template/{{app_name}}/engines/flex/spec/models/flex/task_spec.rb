require 'rails_helper'

RSpec.describe Flex::Task, type: :model do
  let(:kase) { TestCase.create! }
  let(:task) { described_class.create!(case_id: kase.id, description: 'Test task description') }

  context 'when attempting to set readonly attributes' do
    describe 'status attribute' do
      it 'cannot be modified directly' do
        expect { task.status = :completed }.to raise_error(NoMethodError)
      end
    end
    
    describe 'assignee_id attribute' do
      it 'cannot be modified directly' do
        expect { task.assignee_id = SecureRandom.uuid }.to raise_error(NoMethodError)
      end
    end

    describe 'case_id attribute' do
      it 'cannot be modified directly' do
        expect { task.case_id = SecureRandom.uuid }.to raise_error(ActiveRecord::ReadonlyAttributeError)
      end
    end
    
    describe 'type attribute' do
      it 'cannot be modified directly' do
        expect { task.type = SecureRandom.hex }.to raise_error(ActiveRecord::ReadonlyAttributeError)
      end
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

  describe 'validations' do
    it 'validates presence of case_id on create' do
      expect { described_class.create!(case_id: nil) }.to raise_error(ActiveRecord::RecordInvalid, /Validation failed: Case can't be blank/)
    end
  end
end
