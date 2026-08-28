# frozen_string_literal: true

require 'rails_helper'
require 'rake'

RSpec.describe 'strata:events', type: :task do
  let(:event_manager) { class_double(Strata::EventManager) }

  before do
    Rake.application.rake_require('tasks/strata_events')
    Rake::Task.define_task(:environment)
    stub_const('Strata::EventManager', event_manager)
    allow(Strata::EventManager).to receive(:publish)
  end

  describe 'publish_event' do
    let(:task) { Rake::Task['strata:events:publish_event'] }

    after do
      task.reenable
    end

    describe 'argument validation' do
      it 'raises error if event_name is missing' do
        expect {
          task.invoke(nil)
        }.to raise_error(/event_name is required/)
      end
    end

    describe 'successful event emission' do
      before do
        allow(Rails.logger).to receive(:info)
      end

      it 'publishes the event and outputs a message' do
        event_name = Faker::Alphanumeric.alpha(number: rand(5..15))

        task.invoke(event_name)

        expect(Strata::EventManager).to have_received(:publish).with(event_name)
        expect(Rails.logger).to have_received(:info).with(/Event '#{event_name}' emitted successfully/)
      end
    end
  end

  describe 'publish_case_event' do
    let(:task) { Rake::Task['strata:events:publish_case_event'] }

    after do
      task.reenable
    end

    describe 'argument validation' do
      it 'raises error if event_name is missing' do
        expect {
          task.invoke(nil, "TestCase", Faker::Number.digit)
        }.to raise_error(/event_name is required/)
      end

      it 'raises error if case_class is missing' do
        expect {
          task.invoke(Faker::Alphanumeric.alpha(number: 10), nil, Faker::Number.digit)
        }.to raise_error(/case_class is required/)
      end

      it 'raises error if case_id is missing' do
        expect {
          task.invoke(Faker::Alphanumeric.alpha(number: 10), "TestCase", nil)
        }.to raise_error(/case_id is required/)
      end

      it 'raises error if all are missing' do
        expect {
          task.invoke(nil, nil, nil)
        }.to raise_error(/event_name, case_class, and case_id are required/)
      end
    end

    describe 'successful event emission' do
      let(:test_case) { instance_double(TestCase, id: case_id) }
      let(:case_id) { Faker::Number.between(from: 1, to: 1000) }

      before do
        allow(Rails.logger).to receive(:info)
        allow(TestCase).to receive(:find).and_return(test_case)
      end

      it 'finds the case, publishes the event, and outputs a message' do
        event_name = Faker::Alphanumeric.alpha(number: rand(5..15))
        task.invoke(event_name, "TestCase", case_id)

        expect(Strata::EventManager).to have_received(:publish).with(event_name, case_id: case_id)
        expect(Rails.logger).to have_received(:info).with(/Event '#{event_name}' emitted for 'TestCase' with ID '#{case_id}'/)
      end
    end
  end

  describe 'sweep' do
    let(:task) { Rake::Task['strata:events:sweep'] }
    let(:result) { Strata::Events::Sweeper::Result.new(events: 2, deliveries: 3) }

    after do
      task.reenable
    end

    it 'delegates recovery work to the event sweeper' do
      allow(Strata::Events::Sweeper).to receive(:call).and_return(result)
      allow(Rails.logger).to receive(:info)

      task.invoke

      expect(Strata::Events::Sweeper).to have_received(:call)
      expect(Rails.logger).to have_received(:info).with(/processed 2 events and 3 deliveries/)
    end
  end

  describe 'prune' do
    let(:task) { Rake::Task['strata:events:prune'] }
    let(:cutoff) { 90.days.ago }
    let(:result) do
      Strata::Events::Pruner::Result.new(
        cutoff: cutoff,
        events: 4,
        deliveries: 5,
        duration: 0.1,
        dry_run: true
      )
    end

    after do
      task.reenable
    end

    it 'delegates an explicit dry-run retention policy to the pruner' do
      allow(ENV).to receive(:fetch).with("DRY_RUN", false).and_return("1")
      allow(Strata::Events::Pruner).to receive(:call).and_return(result)
      allow(Rails.logger).to receive(:info)

      task.invoke("90")

      expect(Strata::Events::Pruner).to have_received(:call).with(
        older_than_days: "90",
        dry_run: true
      )
      expect(Rails.logger).to have_received(:info).with(/would prune 4 events and 5 deliveries/)
    end
  end
end
