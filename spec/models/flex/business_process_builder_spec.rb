require 'rails_helper'

RSpec.describe Flex::BusinessProcessBuilder do
  describe '#start' do
    let(:builder) { described_class.new(:test, TestCase) }

    it 'sets the start step name' do
      builder.start('test_step')
      expect(builder.instance_variable_get(:@start_step_name)).to eq('test_step')
    end

    it 'creates default ApplicationFormCreated event handler when no event name is provided' do
      builder.start('test_step')
      start_events = builder.instance_variable_get(:@start_events)
      expect(start_events.keys).to include("TestApplicationFormCreated")
    end

    it 'registers custom event handler when event name is provided' do
      custom_handler = ->(event) { TestCase.new }
      builder.start('test_step', on: 'CustomEvent', &custom_handler)

      start_events = builder.instance_variable_get(:@start_events)
      expect(start_events.keys).to include('CustomEvent')
      expect(start_events['CustomEvent']).to eq(custom_handler)
    end
  end
end
