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
    Strata::Events.register("RetryEventHandler")
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
end
