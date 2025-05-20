require 'rails_helper'

RSpec.describe Flex::BusinessProcess do
  let(:application_form) { TestApplicationForm.create!() }
  let(:kase) { TestCase.find_by(application_form_id: application_form.id) }
  let(:business_process) { TestBusinessProcess }

  before do
    business_process.start_listening_for_events
  end

  after do
    # Clean up any subscriptions to avoid side effects in other tests
    business_process.stop_listening_for_events
  end

  describe '#handle_event' do
    before do
      kase.business_process_current_step = 'user_task'
      kase.save!
    end

    it 'executes the complete process chain' do
      Flex::EventManager.publish('event1', { case_id: kase.id })
      # system_process automatically publishes event2
      kase.reload
      expect(kase.business_process_current_step).to eq('user_task_2')

      Flex::EventManager.publish('event3', { case_id: kase.id })
      # system_process_2 automatically publishes event4
      kase.reload
      expect(kase.business_process_current_step).to eq('end')
      expect(kase).to be_closed
    end

    context 'when no transition is defined for the event' do
      it 'maintains current step' do
        [ 'event2', 'event3', 'event4' ].each do |event|
          Flex::EventManager.publish(event, { case_id: kase.id })
        end
        expect(kase.business_process_current_step).to eq('user_task')
      end

      it 'does not re-execute the current step' do
        allow(StaffTaskCreationService).to receive(:create_task)
        [ 'event2', 'event3', 'event4' ].each do |event|
          Flex::EventManager.publish(event, { case_id: kase.id })
        end
        expect(StaffTaskCreationService).not_to have_received(:create_task)
      end
    end
  end

  describe '#stop_listening_for_events' do
    before do
      business_process.start_listening_for_events
      kase.save!
    end

    it 'unsubscribes from all events' do
      business_process.stop_listening_for_events

      # Try publishing various events
      kase.business_process_current_step = 'user_task'
      kase.save!

      Flex::EventManager.publish('event1', { case_id: kase.id })
      kase.reload
      expect(kase.business_process_current_step).to eq('user_task') # Should not change

      Flex::EventManager.publish('event2', { case_id: kase.id })
      kase.reload
      expect(kase.business_process_current_step).to eq('user_task') # Should not change

      Flex::EventManager.publish('event3', { case_id: kase.id })
      kase.reload
      expect(kase.business_process_current_step).to eq('user_task') # Should not change
    end
  end
end
