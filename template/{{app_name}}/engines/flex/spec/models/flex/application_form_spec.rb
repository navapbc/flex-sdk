require "rails_helper"

module Flex
  class TestApplicationForm < ApplicationForm
    attribute :test_string, :string
  end
end

module Flex
  RSpec.describe TestApplicationForm do
    describe "validations" do
      let(:application_form) { described_class.new }
      let(:mock_events_manager) { class_double(EventManager) }

      before do
        stub_const("Flex::EventManager", mock_events_manager)
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
          allow(mock_events_manager).to receive(:publish)

          expect { application_form.submit_application }.not_to raise_error

          expect(application_form.errors).to be_empty
          expect(application_form.status).to eq("submitted")
        end

        it "triggers the event when submitting application" do
          allow(mock_events_manager).to receive(:publish)
          expected_payload = { id: application_form.id }

          application_form.submit_application

          expect(mock_events_manager).to have_received(:publish)
            .with("application_submitted", expected_payload).once
        end

        it "does not trigger an event if an error is raised while saving the form" do
          allow(application_form).to receive(:save!).and_raise("This is a test error")
          allow(mock_events_manager).to receive(:publish)

          expect { application_form.submit_application }.to raise_error("This is a test error")
          expect(mock_events_manager).not_to have_received(:publish)
        end
      end

      context "when form is already submitted" do
        before do
          allow(mock_events_manager).to receive(:publish)
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
end
