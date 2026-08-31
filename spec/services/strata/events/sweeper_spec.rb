# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::Events::Sweeper do
  around do |example|
    original_handlers = Strata::Events.handler_names.dup
    Strata::Events.handler_names.clear
    example.run
  ensure
    Strata::Events.handler_names.replace(original_handlers)
  end

  it "routes undispatched events and completes their deliveries" do
    handler = Class.new do
      def self.event_names = [ "SweepMe" ]
      def self.handle_event(_event) = :handled
    end
    stub_const("SweepEventHandler", handler)
    Strata::Events.register("SweepEventHandler")
    event = Strata::Event.create!(name: "SweepMe", payload: {}, occurred_at: Time.current)

    result = described_class.call

    expect(result.events).to eq(1)
    expect(event.reload.dispatched_at).to be_present
    expect(event.deliveries.sole).to be_handled
  end

  it "retries failed deliveries only after their retry time" do
    handler = Class.new do
      class << self
        attr_accessor :calls

        def event_names = [ "RetryMe" ]

        def handle_event(_event)
          self.calls = calls.to_i + 1
          :handled
        end
      end
    end
    stub_const("RetryEventHandler", handler)
    event = Strata::Event.create!(
      name: "RetryMe",
      payload: {},
      occurred_at: 1.minute.ago,
      dispatched_at: 1.minute.ago
    )
    delivery = event.deliveries.create!(
      handler: "RetryEventHandler",
      status: :failed,
      attempts: 1,
      next_attempt_at: 1.second.ago
    )

    result = described_class.call

    expect(result.deliveries).to eq(1)
    expect(delivery.reload).to be_handled
    expect(handler.calls).to eq(1)
  end

  it "retries persisted deliveries even when the handler is no longer routed" do
    event = Strata::Event.create!(
      name: "OldEventName",
      payload: {},
      occurred_at: 1.minute.ago,
      dispatched_at: 1.minute.ago
    )
    delivery = event.deliveries.create!(
      handler: "RemovedEventHandler",
      status: :failed,
      attempts: 1,
      next_attempt_at: 1.second.ago
    )
    max_attempts = Strata::Events.config.max_attempts
    Strata::Events.config.max_attempts = 2
    allow(Rails.error).to receive(:report)

    result = described_class.call

    expect(result.deliveries).to eq(1)
    expect(delivery.reload).to be_dead_letter
  ensure
    Strata::Events.config.max_attempts = max_attempts
  end

  it "reserves retry capacity when unroutable events fill the event batch" do
    unroutable = Strata::Event.create!(name: "FutureEvent", payload: {}, occurred_at: 1.minute.ago)
    handler = Class.new do
      def self.handle_event(_event) = :handled
    end
    stub_const("IndependentRetryHandler", handler)
    retry_event = Strata::Event.create!(
      name: "RetryMe",
      payload: {},
      occurred_at: 1.minute.ago,
      dispatched_at: 1.minute.ago
    )
    delivery = retry_event.deliveries.create!(
      handler: "IndependentRetryHandler",
      status: :failed,
      attempts: 1,
      next_attempt_at: 1.second.ago
    )

    result = described_class.call(limit: 1)

    expect(result).to have_attributes(events: 1, deliveries: 1)
    expect(unroutable.reload.next_attempt_at).to be > Time.current
    expect(delivery.reload).to be_handled
  end

  it "prioritizes never-attempted events over deferred unroutable events" do
    deferred = Strata::Event.create!(
      name: "FutureEvent",
      payload: {},
      occurred_at: 1.day.ago,
      next_attempt_at: 1.minute.ago
    )
    handler = Class.new do
      def self.event_names = [ "KnownEvent" ]
      def self.handle_event(_event) = :handled
    end
    stub_const("KnownSweepHandler", handler)
    Strata::Events.register("KnownSweepHandler")
    known = Strata::Event.create!(name: "KnownEvent", payload: {}, occurred_at: Time.current)

    result = described_class.call(limit: 1)

    expect(result.events).to eq(1)
    expect(known.reload).to have_attributes(dispatched_at: be_present)
    expect(deferred.reload.dispatched_at).to be_nil
  end

  it "rolls back handler side effects inside the sweep transaction" do
    handler = Class.new do
      def self.event_names = [ "FailDuringSweep" ]

      def self.targets_for_event(event)
        [ TestCase.find(event[:payload][:case_id]) ]
      end

      def self.handle_event(_event, target:)
        target.update!(business_process_current_step: "should_roll_back")
        raise "sweep handler failed"
      end
    end
    stub_const("FailingSweepHandler", handler)
    Strata::Events.register("FailingSweepHandler")
    allow(Rails.error).to receive(:report)
    kase = TestCase.create!(business_process_current_step: "original")
    event = Strata::Event.create!(
      name: "FailDuringSweep",
      payload: { case_id: kase.id },
      occurred_at: Time.current
    )

    described_class.call

    expect(kase.reload.business_process_current_step).to eq("original")
    expect(event.deliveries.sole.reload).to be_failed
  end
end
