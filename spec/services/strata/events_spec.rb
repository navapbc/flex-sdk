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
end
