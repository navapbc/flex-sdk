# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::Events::Dispatcher::Base do
  let(:event) { Strata::Event.create!(name: "TestEvent", payload: {}, occurred_at: Time.current) }

  describe Strata::Events::Dispatcher::Inline do
    it "processes the event only from the after-commit callback" do
      callback = nil
      allow(ActiveRecord).to receive(:after_all_transactions_commit) { |&block| callback = block }
      allow(Strata::Events::Processor).to receive(:call)

      described_class.new.dispatch(event)

      expect(Strata::Events::Processor).not_to have_received(:call)
      callback.call
      expect(Strata::Events::Processor).to have_received(:call).with(event.id, raise_on_failure: true)
    end
  end

  describe Strata::Events::Dispatcher::ActiveJob do
    it "enqueues the dispatch job only from the after-commit callback" do
      callback = nil
      allow(ActiveRecord).to receive(:after_all_transactions_commit) { |&block| callback = block }
      allow(Strata::Events::DispatchJob).to receive(:perform_later)

      described_class.new.dispatch(event)

      expect(Strata::Events::DispatchJob).not_to have_received(:perform_later)
      callback.call
      expect(Strata::Events::DispatchJob).to have_received(:perform_later).with(event.id)
    end
  end
end
