# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::Events::PruneJob, type: :job do
  it "delegates the host's retention policy to the pruner" do
    allow(Strata::Events::Pruner).to receive(:call)

    described_class.perform_now(older_than_days: 90, dry_run: true)

    expect(Strata::Events::Pruner).to have_received(:call).with(
      older_than_days: 90,
      dry_run: true
    )
  end
end
