require "rails_helper"
require "support/matchers/publish_event_with_payload"

RSpec.describe Flex::ApplicationForm do
  describe "validations" do
    let(:application_form) { TestApplicationForm.new }

    before do
      application_form.save!
    end

    context "when attempting to update status" do
      it "prevents direct status updates when setting status directly" do
        expect { application_form.status = "submitted" }.to raise_error(NoMethodError)
      end

      it "prevents direct status updates when calling update method" do
        expect { application_form.update(status: "submitted") }.to raise_error(NoMethodError)
      end
    end

    context "when form is in progress" do
      it "defaults to in progress" do
        expect(application_form.status).to eq("in_progress")
      end

      it "allows changes to attributes" do
        expect(application_form.update(test_string: "a new string!")).to be true
        expect(application_form.test_string).to eq("a new string!")
      end
    end

    context "when submitting a form" do
      it "updates status to submitted upon submitting application" do
        expect { application_form.submit_application }.not_to raise_error

        expect(application_form.errors).to be_empty
        expect(application_form.status).to eq("submitted")
      end

      it "triggers a FormSubmitted event" do
        expected_payload = { application_form_id: application_form.id }
        expect { application_form.submit_application }.to publish_event_with_payload("TestApplicationFormSubmitted", expected_payload)
      end

      it "sets submitted_at timestamp" do
        expect(application_form.submitted_at).to be_nil

        application_form.submit_application

        expect(application_form.submitted_at).to be_within(1.second).of(Time.current)
      end
    end

    context "when form is already submitted" do
      before do
        application_form.test_string = "a string to use when the form is already submitted"
        application_form.save!
        application_form.submit_application
      end

      it "prevents attribute updates from being saved" do
        did_update = application_form.update(test_string: "this should be prevented")
        errors = application_form.errors[:base]

        application_form.reload # reloading the model to ensure that the update did not go through to the database

        expect(did_update).to be(false)
        expect(errors).to include('Cannot modify a submitted application')
        expect(application_form.test_string).to eq("a string to use when the form is already submitted")
      end
    end
  end
end
