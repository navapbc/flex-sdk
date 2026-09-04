# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::Events::DispatchJob, type: :job do
  include ActiveJob::TestHelper

  it "inherits the host application's Active Job adapter" do
    original_adapter = ActiveJob::Base.queue_adapter
    adapter = ActiveJob::QueueAdapters::TestAdapter.new
    ActiveJob::Base.queue_adapter = adapter

    expect(described_class.superclass).to eq(Strata::ApplicationJob)
    expect(described_class.queue_adapter).to equal(adapter)
  ensure
    ActiveJob::Base.queue_adapter = original_adapter
  end

  it "routes one event without enabling adapter-native retry scheduling" do
    allow(Strata::Events::Processor).to receive(:call)

    described_class.perform_now("event-id")

    expect(Strata::Events::Processor).to have_received(:call).with("event-id", raise_on_failure: false)
  end

  it "routes and performs a delivery through Active Job end to end" do
    handler = Class.new do
      def self.event_names = [ "ActiveJobEvent" ]
      def self.handle_event(_event) = :handled
    end
    stub_const("ActiveJobEventHandler", handler)
    original_handlers = Strata::Events.handler_names.dup
    Strata::Events.handler_names.clear
    Strata::Events.register("ActiveJobEventHandler")
    event = Strata::Event.create!(name: "ActiveJobEvent", payload: {}, occurred_at: Time.current)

    perform_enqueued_jobs do
      described_class.perform_later(event.id)
    end

    expect(event.reload.dispatched_at).to be_present
    expect(event.deliveries.sole).to be_handled
  ensure
    Strata::Events.handler_names.replace(original_handlers)
  end
end
