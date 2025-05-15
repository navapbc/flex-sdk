require 'rails_helper'

RSpec.describe Flex::BusinessProcess do
  let(:kase) { TestCase.new }
  let(:case_class) { TestCase }
  let(:business_process) { TestBusinessProcess }

  before do
    business_process.start_listening_for_events
  end

  after do
    # Clean up any subscriptions to avoid side effects in other tests
    business_process.stop_listening_for_events
  end

  describe '#execute' do
    it 'sets the initial step and executes it' do
      expect(kase.business_process_current_step).to be_blank
      business_process.execute(kase)
      expect(kase.business_process_current_step).to eq('user_task')
    end

    it 'maintains current step if already set' do
      kase.business_process_current_step = 'user_task_2'
      business_process.execute(kase)
      expect(kase.business_process_current_step).to eq('user_task_2')
    end
  end

  describe '#handle_event' do
    before do
      business_process.start_listening_for_events
      kase.save!
    end

    after do
      business_process.stop_listening_for_events
    end

    it 'executes the complete process chain' do
      kase.business_process_current_step = 'user_task'

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

    it 'maintains current step when no transition is defined for the event' do
      kase.business_process_current_step = 'user_task'

      [
        'event2', 'event3', 'event4'
      ].each do |event|
        Flex::EventManager.publish(event, { case_id: kase.id })
        kase.reload
        expect(kase.business_process_current_step).to eq('user_task')
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
