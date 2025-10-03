# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Strata::StaffTask do
  describe '#initialize' do
    let(:task_management_service) { instance_double(Strata::TaskService::Base) }
    let(:valid_task_class) { Class.new(Strata::Task) }

    before do
      stub_const("ValidTestTask", valid_task_class)
    end

    it 'initializes successfully with valid arguments' do
      expect {
        described_class.new(ValidTestTask, task_management_service)
      }.not_to raise_error
    end

    it 'raises ArgumentError when task_class is not a Strata::Task subclass' do
      invalid_task_class = Class.new

      expect {
        described_class.new(invalid_task_class, task_management_service)
      }.to raise_error(ArgumentError, "`task_class` must be a Strata::Task or a subclass of Strata::Task")
    end

    it 'raises ArgumentError when task_class is nil' do
      expect {
        described_class.new(nil, task_management_service)
      }.to raise_error(ArgumentError, "`task_class` must be a Strata::Task or a subclass of Strata::Task")
    end
  end
end
