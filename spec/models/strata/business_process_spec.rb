# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Strata::BusinessProcess do
  let(:application_form) { TestApplicationForm.new }
  let(:kase) { TestCase.find_by(application_form_id: application_form.id) }
  let(:business_process_instance) { kase.business_process_instance }
  let(:business_process) { TestBusinessProcess }

  before do
    allow(Strata::Events).to receive(:enqueue)
    Strata::Events.register business_process
  end

  after do
    Strata::Events.unregister business_process
  end

  def dispatch_pending_events
    20.times do
      event = Strata::Event.ready_for_routing.first
      break unless event

      Strata::Events::Processor.call(event.id)
    end

    raise "Too many immediately routable events" if Strata::Event.ready_for_routing.exists?
  end

  describe '#handle_event' do
    before do
      application_form.save!
      dispatch_pending_events
    end

    it 'executes the complete process chain' do
      expect(kase.business_process_instance.current_step).to eq('staff_task')

      Strata::EventManager.publish('event1', { case_id: kase.id })
      # system_process automatically publishes event2
      dispatch_pending_events
      kase.reload
      expect(kase.business_process_instance.current_step).to eq('staff_task_2')

      Strata::EventManager.publish('event3', { case_id: kase.id })
      dispatch_pending_events
      kase.reload
      expect(kase.business_process_instance.current_step).to eq('applicant_task')

      Strata::EventManager.publish('event4', { case_id: kase.id })
      dispatch_pending_events
      kase.reload
      expect(kase.business_process_instance.current_step).to eq('third_party_task')

      Strata::EventManager.publish('event5', { case_id: kase.id })
      # system_process_2 automatically publishes event6
      dispatch_pending_events
      kase.reload
      expect(kase).to be_closed
      expect(kase.business_process_instance.current_step).to eq('end')
    end

    context 'when no transition is defined for the event' do
      it 'maintains current step' do
        [ 'event2', 'event3', 'event4' ].each do |event|
          Strata::EventManager.publish(event, { case_id: kase.id })
        end
        dispatch_pending_events
        expect(kase.business_process_instance.current_step).to eq('staff_task')
      end

      it 'does not re-execute the current step' do
        allow(Strata::TaskService.get).to receive(:create_task)
        [ 'event2', 'event3', 'event4' ].each do |event|
          Strata::EventManager.publish(event, { case_id: kase.id })
        end
        dispatch_pending_events
        expect(Strata::TaskService.get).not_to have_received(:create_task)
      end
    end
  end

  describe 'handler registration' do
    before do
      application_form.save!
      dispatch_pending_events
    end

    it 'stops routing events after the handler is unregistered' do
      Strata::Events.unregister business_process

      expect(kase.business_process_instance.current_step).to eq('staff_task')

      # Try publishing various events

      event1 = Strata::EventManager.publish('event1', { case_id: kase.id })
      kase.reload
      expect(kase.business_process_instance.current_step).to eq('staff_task') # Should not change

      event2 = Strata::EventManager.publish('event2', { case_id: kase.id })
      kase.reload
      expect(kase.business_process_instance.current_step).to eq('staff_task') # Should not change

      event3 = Strata::EventManager.publish('event3', { case_id: kase.id })
      kase.reload
      expect(kase.business_process_instance.current_step).to eq('staff_task') # Should not change
      expect([ event1, event2, event3 ]).to all(have_attributes(dispatched_at: nil))
    end
  end
end
