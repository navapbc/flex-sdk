# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::EventManager do
  let(:dispatcher) do
    Class.new(Strata::Events::Dispatcher::Base) do
      attr_reader :events

      def initialize
        @events = []
      end

      def dispatch(event)
        events << event
      end
    end.new
  end

  around do |example|
    original_dispatcher = Strata::Events.dispatcher
    Strata::Events.dispatcher = dispatcher
    example.run
  ensure
    Strata::Events.dispatcher = original_dispatcher
  end

  describe ".publish" do
    it "persists an event and schedules it with the configured dispatcher" do
      event = described_class.publish("BenefitApplicationSubmitted", case_id: "case-123")

      expect(event).to be_persisted
      expect(event).to have_attributes(
        name: "BenefitApplicationSubmitted",
        payload: { "case_id" => "case-123" },
        causation_id: nil
      )
      expect(event.correlation_id).to be_present
      expect(event.occurred_at).to be_within(1.second).of(Time.current)
      expect(dispatcher.events).to include(event)
    end

    it "remains atomic with the transaction that publishes it" do
      expect {
        ActiveRecord::Base.transaction do
          described_class.publish("RolledBack")
          raise ActiveRecord::Rollback
        end
      }.not_to change(Strata::Event, :count)
    end

    it "preserves synchronous ActiveSupport notifications for instrumentation" do
      callback = instance_double(Proc)
      allow(callback).to receive(:call)
      subscription = described_class.subscribe("Instrumented", callback)

      described_class.publish("Instrumented", value: 42)

      expect(callback).to have_received(:call).with(name: "Instrumented", payload: { value: 42 })
    ensure
      described_class.unsubscribe(subscription) if subscription
    end

    it "propagates correlation and causation from the event being handled" do
      cause = Strata::Event.create!(
        name: "Cause",
        payload: {},
        correlation_id: "correlation-123",
        occurred_at: Time.current
      )

      child = Strata::Events.with_current_event(cause) do
        described_class.publish("Effect")
      end

      expect(child).to have_attributes(
        correlation_id: "correlation-123",
        causation_id: cause.id
      )
    end
  end
end
