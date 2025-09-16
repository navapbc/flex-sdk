require 'rails_helper'

RSpec.describe TestTask, type: :model do
  let(:task) { create(:test_task) }
  let(:event_manager) { class_double(Flex::EventManager) }

  before do
    stub_const('Flex::EventManager', event_manager)
    allow(Flex::EventManager).to receive(:publish)
  end

  context "with status enum methods overwritten" do
    describe '#completed' do
      it 'marks the task as completed' do
        task.completed!
        task.reload

        expect(task.status).to eq('completed')
        expect(task.completed?).to be true
      end

      it 'emits an event as completed' do
        task.completed!

        expect(Flex::EventManager).to have_received(:publish).with("TestTaskCompleted", hash_including(task_id: task.id, case_id: task.case_id)).once
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

        expect(Flex::EventManager).to have_received(:publish).with("TestTaskPending", hash_including(task_id: task.id, case_id: task.case_id)).once
      end
    end

    describe '#approved' do
      it 'marks the task as approved' do
        task.approved!
        task.reload

        expect(task.status).to eq('approved')
        expect(task.approved?).to be true
      end

      it 'emits an event as approved' do
        task.approved!

        expect(Flex::EventManager).to have_received(:publish).with("TestTaskApproved", hash_including(task_id: task.id, case_id: task.case_id)).once
      end
    end

    describe '#denied' do
      it 'marks the task as denied' do
        task.denied!
        task.reload

        expect(task.status).to eq('denied')
        expect(task.denied?).to be true
      end

      it 'emits an event as denied' do
        task.denied!

        expect(Flex::EventManager).to have_received(:publish).with("TestTaskDenied", hash_including(task_id: task.id, case_id: task.case_id)).once
      end
    end
  end
end
