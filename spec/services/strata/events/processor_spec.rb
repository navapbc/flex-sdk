# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::Events::Processor do
  around do |example|
    original_handlers = Strata::Events.handler_names.dup
    Strata::Events.handler_names.clear
    example.run
  ensure
    Strata::Events.handler_names.replace(original_handlers)
  end

  def create_event(name, payload = {})
    Strata::Event.create!(name: name, payload: payload, occurred_at: Time.current)
  end

  it "leaves an unrecognized event undispatched for a later code version" do
    allow(Rails.logger).to receive(:warn)
    event = create_event("FutureVersionEvent")

    described_class.call(event.id, raise_on_failure: true)

    expect(event.reload.dispatched_at).to be_nil
    expect(event.deliveries).to be_empty
    expect(Rails.logger).to have_received(:warn).with(/leaving it undispatched for the sweeper/)
  end

  it "fans out to each registered handler and deduplicates targetless deliveries" do
    first = Class.new do
      class << self
        attr_accessor :calls

        def event_names = [ "SharedEvent" ]

        def handle_event(_event)
          self.calls = calls.to_i + 1
        end
      end
    end
    second = Class.new(first)
    stub_const("FirstSharedHandler", first)
    stub_const("SecondSharedHandler", second)
    Strata::Events.register("FirstSharedHandler")
    Strata::Events.register("SecondSharedHandler")
    event = create_event("SharedEvent")

    2.times { described_class.call(event.id, raise_on_failure: true) }

    expect(event.deliveries.reload.pluck(:handler)).to contain_exactly(
      "FirstSharedHandler",
      "SecondSharedHandler"
    )
    expect(event.deliveries).to all(be_handled)
    expect(first.calls).to eq(1)
    expect(second.calls).to eq(1)
  end

  it "exposes the durable delivery as an external idempotency key" do
    handler = Class.new do
      class << self
        attr_accessor :delivery_id

        def event_names = [ "ExternalCallEvent" ]

        def handle_event(_event)
          self.delivery_id = Strata::Events.current_delivery.id
        end
      end
    end
    stub_const("ExternalCallHandler", handler)
    Strata::Events.register("ExternalCallHandler")
    event = create_event("ExternalCallEvent")

    described_class.call(event.id, raise_on_failure: true)

    expect(handler.delivery_id).to eq(event.deliveries.sole.id)
  end

  it "records no_target when a business-process event cannot resolve a case" do
    Strata::Events.register(TestBusinessProcess)
    event = create_event("event1")

    described_class.call(event.id, raise_on_failure: true)

    expect(event.deliveries.sole).to be_no_target
  end

  it "records no_transition without re-executing the current step" do
    Strata::Events.register(TestBusinessProcess)
    kase = TestCase.create!(business_process_current_step: "staff_task")
    event = create_event("event3", case_id: kase.id)

    described_class.call(event.id, raise_on_failure: true)

    expect(event.deliveries.sole).to be_no_transition
    expect(kase.reload.business_process_current_step).to eq("staff_task")
  end

  it "atomically advances a locked case and records a handled delivery" do
    Strata::Events.register(TestBusinessProcess)
    kase = TestCase.create!(business_process_current_step: "staff_task")
    event = create_event("event1", case_id: kase.id)

    described_class.call(event.id, raise_on_failure: true)

    expect(event.deliveries.sole).to be_handled
    expect(kase.reload.business_process_current_step).to eq("staff_task_2")
    child = Strata::Event.find_by!(name: "event2")
    expect(child.causation_id).to eq(event.id)
    expect(child.correlation_id).to eq(event.correlation_id || event.id)
  end

  it "rolls back handler side effects, records the failure, and reports it" do
    failing_handler = Class.new do
      def self.event_names = [ "FailingEvent" ]

      def self.targets_for_event(event)
        [ TestCase.unscoped.find(event[:payload][:case_id]) ]
      end

      def self.handle_event(_event, target:)
        target.update!(business_process_current_step: "should_roll_back")
        raise "handler failed"
      end
    end
    stub_const("FailingEventHandler", failing_handler)
    Strata::Events.register("FailingEventHandler")
    allow(Rails.error).to receive(:report)
    kase = TestCase.create!(business_process_current_step: "original")
    event = create_event("FailingEvent", case_id: kase.id)

    expect {
      described_class.call(event.id, raise_on_failure: true)
    }.to raise_error(RuntimeError, "handler failed")

    delivery = event.deliveries.sole
    expect(delivery).to be_failed
    expect(delivery).to have_attributes(attempts: 1)
    expect(delivery.next_attempt_at).to be > Time.current
    expect(delivery.last_error).to include("RuntimeError: handler failed")
    expect(kase.reload.business_process_current_step).to eq("original")
    expect(Rails.error).to have_received(:report).with(
      instance_of(RuntimeError),
      handled: false,
      context: hash_including(strata_event_delivery_id: delivery.id)
    )
  end

  it "moves an exhausted retry to the dead letter state" do
    missing_handler = "MissingEventHandler"
    Strata::Events.register(missing_handler)
    event = create_event("MissingHandlerEvent")
    original_attempts = Strata::Events.config.max_attempts
    Strata::Events.config.max_attempts = 1

    described_class.call(event.id, raise_on_failure: false)

    expect(event.deliveries.sole).to be_dead_letter
  ensure
    Strata::Events.config.max_attempts = original_attempts
  end
end
