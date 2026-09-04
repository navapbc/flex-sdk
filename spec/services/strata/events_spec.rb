# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::Events do
  around do |example|
    original_handlers = described_class.handler_names.dup
    described_class.handler_names.clear
    example.run
  ensure
    described_class.reset!
    original_handlers.each { |handler| described_class.register(handler) }
  end

  it "registers deduplicated class-name strings without resolving constants" do
    described_class.register("ReloadableBusinessProcess")
    described_class.register("ReloadableBusinessProcess")

    expect(described_class.handler_names).to eq([ "ReloadableBusinessProcess" ])
  end

  it "enqueues event jobs through the common helper" do
    allow(Strata::Events::DispatchJob).to receive(:perform_later).with("event-id").and_return(:job)

    expect(described_class.enqueue(Strata::Events::DispatchJob, "event-id")).to eq(:job)
  end

  it "reports enqueue failures without raising after commit" do
    allow(Strata::Events::DispatchJob).to receive(:perform_later).and_raise("queue unavailable")
    allow(Rails.error).to receive(:report)
    allow(Rails.logger).to receive(:error)

    expect {
      described_class.enqueue(Strata::Events::DispatchJob, "event-id")
    }.not_to raise_error
    expect(Rails.error).to have_received(:report).with(
      instance_of(RuntimeError),
      handled: true,
      context: hash_including(job_class: "Strata::Events::DispatchJob")
    )
  end

  it "stores host configuration outside the reloadable Events module" do
    described_class.config.max_attempts = 17

    state = Strata::Engine.events_state
    expect(state.configuration.max_attempts).to eq(17)
  end
end
