# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::Events do
  around do |example|
    original_handlers = described_class.handler_names.dup
    original_dispatcher = described_class.dispatcher
    described_class.handler_names.clear
    example.run
  ensure
    described_class.reset!
    original_handlers.each { |handler| described_class.register(handler) }
    described_class.dispatcher = original_dispatcher
  end

  it "registers deduplicated class-name strings without resolving constants" do
    described_class.register("ReloadableBusinessProcess")
    described_class.register("ReloadableBusinessProcess")

    expect(described_class.handler_names).to eq([ "ReloadableBusinessProcess" ])
  end

  it "defaults to the inline dispatcher" do
    described_class.reset!

    expect(described_class.dispatcher).to be_a(Strata::Events::Dispatcher::Inline)
  end

  it "rejects objects that do not implement the dispatcher base interface" do
    expect {
      described_class.dispatcher = Object.new
    }.to raise_error(ArgumentError, /Dispatcher must be a subclass/)
  end

  it "stores host configuration outside the reloadable Events module" do
    described_class.config.max_attempts = 17
    dispatcher = Strata::Events::Dispatcher::ActiveJob.new
    described_class.dispatcher = dispatcher

    state = Strata::Engine.events_state
    expect(state.configuration.max_attempts).to eq(17)
    expect(state.dispatcher).to equal(dispatcher)
  end
end
