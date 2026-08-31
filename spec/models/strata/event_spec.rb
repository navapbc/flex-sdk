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

  it "allows dispatch bookkeeping while preventing persisted content changes" do
    event.save!

    expect {
      event.update!(dispatched_at: Time.current, next_attempt_at: 1.minute.from_now)
    }.not_to raise_error

    expect {
      event.update!(payload: { changed: true })
    }.to raise_error(ActiveRecord::ReadOnlyRecord, /immutable/)

    expect {
      event.update!(id: SecureRandom.uuid)
    }.to raise_error(ActiveRecord::ReadOnlyRecord, /immutable/)
  end

  it "prevents ordinary destruction of persisted event history" do
    event.save!

    expect { event.destroy! }.to raise_error(ActiveRecord::ReadOnlyRecord, /audited event pruner/)
    expect { event.delete }.to raise_error(ActiveRecord::ReadOnlyRecord, /audited event pruner/)
    expect(described_class.where(id: event.id)).to exist
  end
end
