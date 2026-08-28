# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::Events::Pruner do
  around do |example|
    retention_days = Strata::Events.config.retention_days
    delivery_retention_days = Strata::Events.config.delivery_retention_days
    Strata::Events.config.delivery_retention_days = nil
    example.run
  ensure
    Strata::Events.config.retention_days = retention_days
    Strata::Events.config.delivery_retention_days = delivery_retention_days
  end

  def create_event(age:, status: :handled)
    event = Strata::Event.create!(
      name: "RetentionEvent",
      payload: {},
      occurred_at: age.ago,
      dispatched_at: age.ago
    )
    event.deliveries.create!(handler: "RetentionHandler", status: status)
    event
  end

  it "raises rather than assuming a retention window" do
    Strata::Events.config.retention_days = nil

    expect {
      described_class.call
    }.to raise_error(ArgumentError, /must be explicitly configured/)
  end

  it "refuses to delete history when it cannot write an audit record" do
    old_event = create_event(age: 100.days)
    connection = ActiveRecord::Base.connection
    allow(connection).to receive(:data_source_exists?).and_call_original
    allow(connection).to receive(:data_source_exists?)
      .with("strata_audit_lines")
      .and_return(false)

    expect {
      described_class.call(older_than_days: 90)
    }.to raise_error(RuntimeError, /Install Strata::AuditLog/)

    expect(Strata::Event.where(id: old_event.id)).to exist
  end

  it "uses the configured window when an explicit argument is absent" do
    Strata::Events.config.retention_days = 90
    old_event = create_event(age: 100.days)

    described_class.call

    expect(Strata::Event.where(id: old_event.id)).not_to exist
  end

  it "deletes old terminal events with their deliveries and writes an audit line" do
    old_event = create_event(age: 100.days)
    recent_event = create_event(age: 10.days)

    expect {
      result = described_class.call(older_than_days: 90)
      expect(result).to have_attributes(events: 1, deliveries: 1, dry_run: false)
      expect(result.cutoff).to be_within(1.second).of(90.days.ago)
    }.to change(Strata::AuditLine, :count).by(1)

    expect(Strata::Event.where(id: old_event.id)).not_to exist
    expect(Strata::Event.where(id: recent_event.id)).to exist
    expect(Strata::AuditLine.latest_first.first).to have_attributes(action: "events.pruned")
  end

  it "never deletes an event with non-terminal delivery work" do
    pending_event = create_event(age: 100.days, status: :pending)
    failed_event = create_event(age: 100.days, status: :failed)

    described_class.call(older_than_days: 90)

    expect(Strata::Event.where(id: [ pending_event.id, failed_event.id ]).count).to eq(2)
  end

  it "reports counts and cutoff without deleting in dry-run mode" do
    old_event = create_event(age: 100.days)

    expect {
      result = described_class.call(older_than_days: 90, dry_run: true)
      expect(result).to have_attributes(events: 1, deliveries: 1, dry_run: true)
    }.not_to change(Strata::AuditLine, :count)

    expect(Strata::Event.where(id: old_event.id)).to exist
  end
end
