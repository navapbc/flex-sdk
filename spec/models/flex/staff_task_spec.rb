require 'rails_helper'

RSpec.describe Flex::StaffTask do
  describe '#initialize' do
    let(:task_management_service) { instance_double(Flex::TaskService::Base) }
    let(:valid_task_class) { Class.new(Flex::Task) }

    before do
      stub_const("ValidTestTask", valid_task_class)
    end

    it 'initializes successfully with valid arguments' do
      expect {
        described_class.new(ValidTestTask, task_management_service)
      }.not_to raise_error
    end

    it 'raises ArgumentError when task_class is not a Flex::Task subclass' do
      invalid_task_class = Class.new

      expect {
        described_class.new(invalid_task_class, task_management_service)
      }.to raise_error(ArgumentError, "`task_class` must be a Flex::Task or a subclass of Flex::Task")
    end

    it 'raises ArgumentError when task_class is nil' do
      expect {
        described_class.new(nil, task_management_service)
      }.to raise_error(ArgumentError, "`task_class` must be a Flex::Task or a subclass of Flex::Task")
    end
  end
end
