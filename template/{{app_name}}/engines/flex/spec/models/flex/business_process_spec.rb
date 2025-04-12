require 'rails_helper'

module Flex
  RSpec.describe BusinessProcess do
    let(:business_process) { described_class.new(name: "Test Business Process", type: PassportCase) }
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
  end
end
