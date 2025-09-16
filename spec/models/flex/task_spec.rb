require 'rails_helper'

RSpec.describe Flex::Task, type: :model do
  let(:kase) { create(:test_case) }
  let(:task) { kase.create_task(described_class, description: Faker::Quote.yoda) }
  let(:event_manager) { class_double(Flex::EventManager) }

  before do
    stub_const('Flex::EventManager', event_manager)
    allow(Flex::EventManager).to receive(:publish)
  end

  describe 'polymorphic associations' do
    let(:foo_case) { FooTestCase.create! }

    it 'belongs to a polymorphic case' do
      expect(task.case).to eq(kase)
      expect(task.case_type).to eq('TestCase')
    end

    it 'can be associated with different case types' do
      new_task = described_class.create!(case: foo_case)
      expect(new_task.case).to eq(foo_case)
      expect(new_task.case_type).to eq('FooTestCase')
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
      foo_task = described_class.create!(case: foo_case)
      expect(described_class.where(case_type: 'TestCase')).to include(task)
      expect(described_class.where(case_type: 'FooTestCase')).to include(foo_task)
    end
  end

  context 'when attempting to set readonly attributes' do
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

  context "with enum methods" do
    describe '#completed' do
      it 'marks the task as completed' do
        task.completed!
        task.reload

        expect(task.status).to eq('completed')
        expect(task.completed?).to be true
      end

      it 'emits an event as completed' do
        task.completed!

        expect(Flex::EventManager).to have_received(:publish).with("Flex::TaskCompleted", hash_including(task_id: task.id, case_id: task.case_id)).once
      end
    end

    describe '#pending' do
      it 'marks the task as pending' do
        task.pending!
        task.reload

        expect(task.status).to eq('pending')
        expect(task.pending?).to be true
      end

      it 'emits an event as pending' do
        task.completed! # Set it to completed first to ensure a status change
        task.pending!

        expect(Flex::EventManager).to have_received(:publish).with("Flex::TaskPending", hash_including(task_id: task.id, case_id: task.case_id)).once
      end
    end
  end

  describe 'validations' do
    it 'validates presence of case on create' do
      expect { described_class.create! }.to raise_error(ActiveRecord::RecordInvalid, /Validation failed: Case must exist/)
    end
  end
end
