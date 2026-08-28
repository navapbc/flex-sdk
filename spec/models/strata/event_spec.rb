# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::Event do
  subject(:event) { described_class.new(name: "TestEvent", occurred_at: Time.current) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:occurred_at) }
  it { is_expected.to have_many(:deliveries).dependent(:destroy) }

  it "provides the symbol-keyed compatibility message expected by handlers" do
    event.payload = { "case_id" => "123", "nested" => { "answer" => 42 } }

    expect(event.message).to eq(
      name: "TestEvent",
      payload: { case_id: "123", nested: { answer: 42 } }
    )
  end
end
