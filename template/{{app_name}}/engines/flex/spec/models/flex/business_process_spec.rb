require 'rails_helper'

module Flex
  RSpec.describe BusinessProcess do
    let(:business_process) { BusinessProcess.new }

    describe 'validations' do
      it 'requires a name' do
        expect(business_process.valid?).to be false
        business_process.name = 'Test Process'
        expect(business_process.valid?).to be true
      end
    end

    describe '#execute' do
      let(:transitions) {{
        "review passport photo" => 'end',
        "collect application info" => 'verify identity',
        "verify identity" => 'review passport photo',
      }}
      let(:mock_step) { double('step') }
      let(:mock_step2) { double('step') }
      let(:mock_case) { double('case', business_process_current_step: 'step1') }
      
      before do
        business_process.define_steps({
          "step1" => mock_step,
          "step2" => mock_step2
        })
        business_process.define_transitions({
          "step1" => 'step2',
          "step2" => 'end',
        })
        business_process.define_start('step1')
        allow(mock_step).to receive(:execute)
      end

      it 'executes remaining steps' do
        expect(mock_step).to receive(:execute).with(mock_case)
        expect(mock_step2).to receive(:execute).with(mock_case)
        business_process.execute(mock_case)
      end
    end
  end
end
