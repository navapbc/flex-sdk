# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::EventDelivery do
  subject(:delivery) { described_class.new(handler: "TestHandler") }

  it { is_expected.to belong_to(:event) }
  it { is_expected.to validate_presence_of(:handler) }

  it { expect(delivery).to define_enum_for(:status).with_values(
    pending: 0,
    handled: 1,
    no_transition: 2,
    no_target: 3,
    failed: 4,
    dead_letter: 5
  ) }

  it "treats successful, discarded, and dead-letter outcomes as terminal" do
    %w[handled no_transition no_target dead_letter].each do |status|
      expect(described_class.new(status: status)).to be_terminal
    end
    expect(described_class.new(status: :pending)).not_to be_terminal
    expect(described_class.new(status: :failed)).not_to be_terminal
  end
end
