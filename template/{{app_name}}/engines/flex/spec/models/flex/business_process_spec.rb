require 'rails_helper'

module Flex
  RSpec.describe BusinessProcess do
    let(:business_process) { described_class.new(name: "Test Business Process") }
    let(:mock_events_manager) { class_double(EventsManager) }

    before do
      stub_const("Flex::EventsManager", mock_events_manager)
    end

    describe 'executing a business process' do
      let(:mock_steps) { {
        "user_task" => instance_double(UserTask,),
        "system_process" => instance_double(SystemProcess),
        "user_task_2" => instance_double(UserTask),
        "system_process_2" => instance_double(SystemProcess)
        }
      }
      let(:mock_case) { instance_double(PassportCase, business_process_current_step: 'step1') }

      before do
        business_process.define_steps(mock_steps)
        allow(mock_steps["user_task"]).to receive(:execute)
        allow(mock_steps["system_process"]).to receive(:execute)
        allow(mock_steps["user_task_2"]).to receive(:execute)
        allow(mock_steps["system_process_2"]).to receive(:execute)
      end

      [
        "user_task",
        "system_process",
        "user_task_2",
        "system_process_2"
      ].each do |starting_step|
        it "only executes the starting step (#{starting_step}) in the business process and not any additional steps" do
          business_process.define_start(starting_step)

          business_process.execute(mock_case)

          expect(mock_steps[starting_step]).to have_received(:execute).with(mock_case)
          expect(mock_steps.except(starting_step).values).to all(have_received(:execute).exactly(0).times)
        end
      end
    end

    describe 'managing events' do
      before do
        allow(mock_events_manager).to receive(:subscribe).and_return({})
      end

      describe '#add_event_listener' do
        it 'raises an error if an event listener with that event key already exists' do
          business_process.add_event_listener("flex.test_event", -> { puts "Step 1 completed" })
          expect {
            business_process.add_event_listener("flex.test_event", -> { puts "Another listener" })
          }.to raise_error("Event listener for flex.test_event already exists")
        end

        it 'allows adding multiple event listeners' do
          expect {
            business_process.add_event_listener("flex.test_event", -> { puts "Step 1 completed" })
            business_process.add_event_listener("flex.test_event2", -> { puts "Step 2 completed" })
            business_process.add_event_listener("flex.test_event3", -> { puts "Step 3 completed" })
            business_process.add_event_listener("flex.test_event4", -> { puts "Step 4 completed" })
          }.not_to raise_error
        end

        it 'adds the event listener to events being listened to' do
          business_process.add_event_listener("flex.test_event", -> { puts "Step 1 completed" })

          expect(business_process.get_events_being_listened_to).to include("flex.test_event")
        end

        it 'subscribes the event listener to the events manager' do
          business_process.add_event_listener("flex.test_event", -> { puts "Step 1 completed" })

          expect(mock_events_manager).to have_received(:subscribe).with("flex.test_event", anything)
        end
      end

      describe '#remove_event_listener' do
        before do
          allow(mock_events_manager).to receive(:unsubscribe)
        end

        it 'raises an error if no event listener is found for the given event key' do
          expect {
            business_process.remove_event_listener("flex.non_existent_event")
          }.to raise_error("No event listener found for flex.non_existent_event")
        end

        it 'does not raise an error when attempting to remove an existing event listener if the event listener exists' do
          business_process.add_event_listener("flex.test_event", -> { puts "Step 1 completed" })

          expect {
            business_process.remove_event_listener("flex.test_event")
          }.not_to raise_error
        end

        it 'unsubscribes the event listener from the events manager' do
          subscription = instance_double(ActiveSupport::Subscriber)
          allow(mock_events_manager).to receive(:subscribe).and_return(subscription)
          business_process.add_event_listener("flex.test_event", -> { puts "Step 1 completed" })

          business_process.remove_event_listener("flex.test_event")

          expect(mock_events_manager).to have_received(:unsubscribe).with(subscription)
        end

        it 'removes the event listener from events being listened to' do
          business_process.add_event_listener("flex.test_event", -> { puts "Step 1 completed" })

          business_process.remove_event_listener("flex.test_event")

          expect(business_process.get_events_being_listened_to).not_to include("flex.test_event")
        end
      end
    end
  end
end
