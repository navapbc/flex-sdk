# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Interactive passport business process", type: :request do
  around do |example|
    original_handlers = Strata::Events.handler_names.dup
    Strata::Events.register("PassportBusinessProcess")
    example.run
  ensure
    Strata::Events.handler_names.replace(original_handlers)
  end

  before do
    allow(Strata::Events).to receive(:enqueue)
  end

  def dispatch_pending_events
    20.times do
      event = Strata::Event.ready_for_routing.first
      break unless event

      Strata::Events::Processor.call(event.id)
    end

    raise "Too many immediately routable events" if Strata::Event.ready_for_routing.exists?
  end

  it "walks a real passport application through the complete workflow" do
    get passport_business_process_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include("Follow a passport application from start to finish")
    expect(response.body).to include("usa-breadcrumb__list")

    expect {
      post start_passport_business_process_path
      dispatch_pending_events
    }.to change(PassportApplicationForm, :count).by(1)
      .and change(PassportCase, :count).by(1)

    expect(response).to redirect_to(passport_business_process_path)
    application_form = PassportApplicationForm.order(:created_at).last
    passport_case = PassportCase.find_by!(application_form_id: application_form.id)
    expect(passport_case.business_process_current_step).to eq("submit_application")

    post advance_passport_business_process_path,
      params: { transition: "submit_application" }
    dispatch_pending_events

    expect(response).to redirect_to(passport_business_process_path)
    expect(application_form.reload).to be_submitted
    expect(passport_case.reload.business_process_current_step).to eq("review_passport_photo")
    expect(passport_case.tasks).to include(an_instance_of(PassportPhotoTask))

    get passport_business_process_path

    expect(response.body).to include("Review the passport photo")
    expect(response.body).to include("PassportApplicationFormSubmitted")
    expect(response.body).to include("IdentityVerified")

    post advance_passport_business_process_path,
      params: { transition: "approve_photo" }
    dispatch_pending_events

    expect(response).to redirect_to(passport_business_process_path)
    expect(passport_case.reload).to be_closed
    expect(passport_case.business_process_current_step).to eq("end")

    get passport_business_process_path

    expect(response.body).to include("Passport approved")
    expect(response.body).to include("PassportPhotoApproved")
    expect(response.body).to include("Case closed")
  end

  it "rejects workflow actions when no run is active" do
    post advance_passport_business_process_path,
      params: { transition: "submit_application" }

    expect(response).to redirect_to(passport_business_process_path)
    follow_redirect!
    expect(response.body).to include("usa-alert usa-alert--warning")
    expect(response.body).to include("Start a workflow run before advancing it")
  end
end
