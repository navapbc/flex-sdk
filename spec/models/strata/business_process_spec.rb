# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Strata::BusinessProcess do
  let(:application_form) { TestApplicationForm.new }
  let(:kase) { TestCase.find_by(application_form_id: application_form.id) }
  let(:business_process_instance) { kase.business_process_instance }
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
      application_form.save!
    end

    it 'executes the complete process chain' do
      expect(kase.business_process_instance.current_step).to eq('staff_task')

      Strata::EventManager.publish('event1', { case_id: kase.id })
      # system_process automatically publishes event2
      kase.reload
      expect(kase.business_process_instance.current_step).to eq('staff_task_2')

      Strata::EventManager.publish('event3', { case_id: kase.id })
      kase.reload
      expect(kase.business_process_instance.current_step).to eq('applicant_task')

      Strata::EventManager.publish('event4', { case_id: kase.id })
      kase.reload
      expect(kase.business_process_instance.current_step).to eq('third_party_task')

      Strata::EventManager.publish('event5', { case_id: kase.id })
      # system_process_2 automatically publishes event6
      kase.reload
      expect(kase).to be_closed
      expect(kase.business_process_instance.current_step).to eq('end')
    end

    context 'when no transition is defined for the event' do
      it 'maintains current step' do
        [ 'event2', 'event3', 'event4' ].each do |event|
          Strata::EventManager.publish(event, { case_id: kase.id })
        end
        expect(kase.business_process_instance.current_step).to eq('staff_task')
      end

      it 'does not re-execute the current step' do
        allow(Strata::TaskService.get).to receive(:create_task)
        [ 'event2', 'event3', 'event4' ].each do |event|
          Strata::EventManager.publish(event, { case_id: kase.id })
        end
        expect(Strata::TaskService.get).not_to have_received(:create_task)
      end
    end
  end

  describe '#stop_listening_for_events' do
    before do
      application_form.save!
    end

    it 'unsubscribes from all events' do
      business_process.stop_listening_for_events

      expect(kase.business_process_instance.current_step).to eq('staff_task')

      # Try publishing various events

      Strata::EventManager.publish('event1', { case_id: kase.id })
      kase.reload
      expect(kase.business_process_instance.current_step).to eq('staff_task') # Should not change

      Strata::EventManager.publish('event2', { case_id: kase.id })
      kase.reload
      expect(kase.business_process_instance.current_step).to eq('staff_task') # Should not change

      Strata::EventManager.publish('event3', { case_id: kase.id })
      kase.reload
      expect(kase.business_process_instance.current_step).to eq('staff_task') # Should not change
    end
  end
end
