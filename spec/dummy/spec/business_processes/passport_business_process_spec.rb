# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PassportBusinessProcess, type: :model do
  let(:test_form) { build(:passport_application_form) }

  before do
    allow(Strata::Events).to receive(:enqueue)
    Strata::Events.register described_class
  end

  after do
    Strata::Events.unregister described_class
  end

  def dispatch_pending_events
    20.times do
      event = Strata::Event.ready_for_routing.first
      break unless event

      Strata::Events::Processor.call(event.id)
    end
    raise "Too many immediately routable events" if Strata::Event.ready_for_routing.exists?
  end

  it "creates a passport case upon starting a passport application form and properly progresses through steps" do
    # create new application
    test_form.save!
    dispatch_pending_events

    # check case created and open with correct current step
    kase = PassportCase.find_by_application_form_id(test_form.id)
    expect(kase).not_to be_nil
    expect(kase.status).to eq ("open")
    expect(kase.business_process_instance.current_step).to eq ("submit_application")

    # submit application
    test_form.name = Strata::Name.new(first: "John", last: "Doe")
    test_form.date_of_birth = Date.new(1990, 1, 1)
    test_form.save!
    test_form.submit_application
    dispatch_pending_events
    kase.reload
    expect(kase.business_process_instance.current_step).to eq ("review_passport_photo")

    # approve passport photo
    Strata::EventManager.publish("PassportPhotoApproved", { case_id: kase.id })
    dispatch_pending_events

    # check case status
    kase.reload
    expect(kase).to be_closed
    expect(kase.business_process_instance.current_step).to eq ("end")
  end
end
