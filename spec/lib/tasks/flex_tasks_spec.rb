require 'rails_helper'
require 'rake'

RSpec.describe 'flex:publish_event', type: :task do
  let(:task) { Rake::Task['flex:publish_event'] }
  let(:event_manager) { class_double(Flex::EventManager) }

  before do
    Rake.application.rake_require('tasks/flex_tasks')
    Rake::Task.define_task(:environment)
    stub_const('Flex::EventManager', event_manager)
    allow(Flex::EventManager).to receive(:publish)
  end

  after do
    task.reenable
  end

  describe 'argument validation' do
    it 'raises error if event_name is missing' do
      expect {
        task.invoke(nil, "TestCase", Faker::Number.digit)
      }.to raise_error(/event_name, case_class, and case_id are required/)
    end

    it 'raises error if case_class is missing' do
      expect {
        task.invoke(Faker::String.random(length: 3..30), nil, Faker::Number.digit)
      }.to raise_error(/event_name, case_class, and case_id are required/)
    end

    it 'raises error if case_id is missing' do
      expect {
        task.invoke(Faker::String.random(length: 3..30), "TestCase", nil)
      }.to raise_error(/event_name, case_class, and case_id are required/)
    end
  end

  describe 'successful event emission' do
    let(:test_case) { instance_double(TestCase) }

    it 'finds the case, publishes the event, and outputs a message' do
      event_name = Faker::String.random(length: 3..30)
      case_id = Faker::Number.between(from: 1, to: 1000)
      allow(TestCase).to receive(:find).with(case_id).and_return(test_case)

      expect {
        Rake::Task['flex:publish_event'].invoke(event_name, "TestCase", case_id)
      }.to output(/Event '#{event_name}' emitted for 'TestCase' with ID '#{case_id}'/).to_stdout
      expect(Flex::EventManager).to have_received(:publish).with(event_name, hash_including(kase: test_case))
    end
  end
end
