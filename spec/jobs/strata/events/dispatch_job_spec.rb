# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::Events::DispatchJob, type: :job do
  it "delegates without enabling ActiveJob retry scheduling" do
    allow(Strata::Events::Processor).to receive(:call)

    described_class.perform_now("event-id")

    expect(Strata::Events::Processor).to have_received(:call).with(
      "event-id",
      raise_on_failure: false
    )
  end
end
