require 'rails_helper'

RSpec.describe Flex::Task, type: :model do
  let(:kase) { create(:test_case) }
  let(:task) { create(:flex_task, case: kase, description: Faker::Quote.yoda) }

  describe 'polymorphic associations' do
    let(:other_case) { OtherTestCase.create! }

    it 'belongs to a polymorphic case' do
      expect(task.case).to eq(kase)
      expect(task.case_type).to eq('TestCase')
    end

    it 'can be associated with different case types' do
      new_task = described_class.create!(case: other_case)
      expect(new_task.case).to eq(other_case)
      expect(new_task.case_type).to eq('OtherTestCase')
    end

    it 'can find all tasks for a case' do
      task2 = described_class.create!(case: kase)
      expect(kase.tasks).to contain_exactly(task, task2)
    end

    it 'maintains case association through updates' do
      task.update!(description: 'Updated')
      expect(task.reload.case).to eq(kase)
    end

    it 'can be queried by case type' do
      other_task = described_class.create!(case: other_case)
      expect(described_class.where(case_type: 'TestCase')).to include(task)
      expect(described_class.where(case_type: 'OtherTestCase')).to include(other_task)
    end
  end

  context 'when attempting to set readonly attributes' do
    describe 'status attribute' do
      it 'cannot be modified directly' do
        expect { task.status = :completed }.to raise_error(NoMethodError)
      end
    end

    describe 'assignee_id attribute' do
      it 'cannot be modified directly' do
        expect { task.assignee_id = Faker::Number.non_zero_digit }.to raise_error(NoMethodError)
      end
    end

    describe 'case_id attribute' do
      it 'cannot be modified directly' do
        expect { task.case_id = Faker::Number.non_zero_digit }.to raise_error(ActiveRecord::ReadonlyAttributeError)
      end
    end

    describe 'type attribute' do
      it 'cannot be modified directly' do
        expect { task.type = Faker::String.random(length: 3..30) }.to raise_error(ActiveRecord::ReadonlyAttributeError)
      end
    end
  end

  describe '#assign' do
    let(:user) { User.create!(first_name: Faker::Name.first_name, last_name: Faker::Name.last_name) }

    it 'assigns the task to the given user' do
      assignee_id = user.id

      task.assign(assignee_id)
      task.reload # reload the task from the db to ensure it was properly assigned

      expect(task.assignee_id).to eq(assignee_id)
    end
  end

  describe '#unassign' do
    let(:user) { User.create!(first_name: Faker::Name.first_name, last_name: Faker::Name.last_name) }

    it 'removes the assignee from the task' do
      task.assign(user.id)

      task.unassign
      task.reload # reload the task from the db to ensure it was properly unassigned

      expect(task.assignee_id).to be_nil
    end
  end

  describe '#mark_completed' do
    it 'marks the task as completed' do
      task.mark_completed
      task.reload # reload the task from the db to ensure it was properly marked completed

      expect(task.status).to eq('completed')
    end
  end

  describe '#mark_pending' do
    it 'marks the task as pending' do
      task.mark_completed

      task.mark_pending
      task.reload # reload the task from the db to ensure it was properly marked pending

      expect(task.status).to eq('pending')
    end
  end

  describe '#from_case' do
    let (:from_case_task) { described_class.from_case(kase) }

    it 'creates a new task associated with the given case' do
      expect(from_case_task).to be_a(described_class)
    end

    it 'sets the new task case_id to the given case id' do
      expect(from_case_task.case_id).to eq(kase.id)
    end

    it 'creates a new, non-persisted record' do
      expect(from_case_task).to be_new_record
    end
  end

  describe 'validations' do
    it 'validates presence of case_id on create' do
      expect { described_class.create!(case_id: nil) }.to raise_error(ActiveRecord::RecordInvalid, /Validation failed: Case can't be blank/)
    end
  end

  describe '#complete?' do
    it 'returns true if the task is completed' do
      task.mark_completed
      expect(task.complete?).to be true
    end

    it 'returns false if the task is not completed' do
      expect(task.complete?).to be false
    end
  end

  describe '#incomplete?' do
    it 'returns true if the task is not completed' do
      expect(task.incomplete?).to be true
    end

    it 'returns false if the task is completed' do
      task.mark_completed
      expect(task.incomplete?).to be false
    end
  end
end
