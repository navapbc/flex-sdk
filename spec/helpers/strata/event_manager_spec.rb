# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::EventManager do
  before do
    allow(Strata::Events).to receive(:enqueue)
  end

  describe ".publish" do
    it "persists an event and schedules its routing job after commit" do
      event = described_class.publish("BenefitApplicationSubmitted", case_id: "case-123")

      expect(event).to be_persisted
      expect(event).to have_attributes(
        name: "BenefitApplicationSubmitted",
        payload: { "case_id" => "case-123" },
        causation_id: nil
      )
      expect(event.correlation_id).to be_present
      expect(event.occurred_at).to be_within(1.second).of(Time.current)
      expect(Strata::Events).to have_received(:enqueue).with(Strata::Events::DispatchJob, event.id)
    end

    it "remains atomic with the transaction that publishes it" do
      expect {
        ActiveRecord::Base.transaction do
          described_class.publish("RolledBack")
          raise ActiveRecord::Rollback
        end
      }.not_to change(Strata::Event, :count)
      expect(Strata::Events).not_to have_received(:enqueue)
    end

    it "propagates correlation and causation from the event being handled" do
      cause = Strata::Event.create!(
        name: "Cause",
        payload: {},
        correlation_id: "correlation-123",
        occurred_at: Time.current
      )

      child = Strata::Events.with_current_event(cause) do
        described_class.publish("Effect")
      end

      expect(child).to have_attributes(
        correlation_id: "correlation-123",
        causation_id: cause.id
      )
    end
  end
end
