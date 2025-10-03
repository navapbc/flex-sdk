# frozen_string_literal: true

require "rails_helper"
require "support/matchers/publish_event_with_payload"

RSpec.describe Strata::ApplicationForm do
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

    context "with validation contexts" do
      let(:application_form) { TestApplicationForm.create! }

      before do
        TestApplicationForm.validates :test_string, presence: true, on: :submit
      end

      after do
        TestApplicationForm.clear_validators!
      end

      it "validates with submit context before proceeding" do
        application_form.test_string = nil

        result = application_form.submit_application

        expect(result).to be false
        expect(application_form.status).to eq("in_progress")
        expect(application_form.submitted_at).to be_nil
        expect(application_form.errors[:test_string]).to include("can't be blank")
      end

      it "proceeds with submission when submit context validations pass" do
        application_form.test_string = "valid value"

        result = application_form.submit_application

        expect(result).to be true
        expect(application_form.status).to eq("submitted")
        expect(application_form.submitted_at).to be_present
        expect(application_form.errors).to be_empty
      end

      it "runs both submit context and default validations during submission" do
        TestApplicationForm.validates :test_string, length: { minimum: 10 }
        application_form.test_string = "short"

        result = application_form.submit_application

        expect(result).to be false
        expect(application_form.status).to eq("in_progress")
        expect(application_form.errors[:test_string]).to include("is too short (minimum is 10 characters)")
      end

      it "does not run submit context validations during regular save" do
        application_form.test_string = nil

        result = application_form.save

        expect(result).to be true
        expect(application_form.errors).to be_empty
      end

      it "does not publish event or set submitted_at when validations fail" do
        application_form.test_string = nil

        expect { application_form.submit_application }.not_to publish_event_with_payload("TestApplicationFormSubmitted", anything)
        expect(application_form.submitted_at).to be_nil
      end

      it "validates submit context before running callbacks" do
        callback_executed = false
        TestApplicationForm.set_callback(:submit, :before) { callback_executed = true }
        application_form.test_string = nil

        application_form.submit_application

        expect(callback_executed).to be false
      end

      it "passes when both regular and submit context validations succeed" do
        TestApplicationForm.validates :test_string, length: { minimum: 3 }
        application_form.test_string = "valid value"

        result = application_form.submit_application

        expect(result).to be true
        expect(application_form.errors).to be_empty
        expect(application_form.status).to eq("submitted")
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

  describe "submit callbacks" do
    let(:application_form) { TestApplicationForm.new }

    before do
      application_form.save!
    end

    after do
      TestApplicationForm.reset_callbacks(:submit)
      PassportApplicationForm.reset_callbacks(:submit)
    end

    describe "before_submit callback" do
      it "executes before_submit callback" do
        callback_executed = false
        TestApplicationForm.set_callback(:submit, :before) { callback_executed = true }

        application_form.submit_application

        expect(callback_executed).to be true
        expect(application_form.status).to eq("submitted")
      end

      it "supports conditional callbacks with if option" do
        callback_executed = false
        TestApplicationForm.set_callback(:submit, :before, if: -> { test_string == "execute" }) { callback_executed = true }

        application_form.test_string = "execute"
        application_form.submit_application

        expect(callback_executed).to be true
      end

      it "skips conditional callbacks when condition is false" do
        callback_executed = false
        TestApplicationForm.set_callback(:submit, :before, if: -> { test_string == "execute" }) { callback_executed = true }

        application_form.test_string = "skip"
        application_form.submit_application

        expect(callback_executed).to be false
        expect(application_form.status).to eq("submitted")
      end

      it "supports conditional callbacks with unless option" do
        callback_executed = false
        TestApplicationForm.set_callback(:submit, :before, unless: -> { test_string == "skip" }) { callback_executed = true }

        application_form.test_string = "execute"
        application_form.submit_application

        expect(callback_executed).to be true
      end

      it "skips conditional callbacks when unless condition is true" do
        callback_executed = false
        TestApplicationForm.set_callback(:submit, :before, unless: -> { test_string == "skip" }) { callback_executed = true }

        application_form.test_string = "skip"
        application_form.submit_application

        expect(callback_executed).to be false
        expect(application_form.status).to eq("submitted")
      end

      it "can abort submission using throw :abort" do
        TestApplicationForm.set_callback(:submit, :before) { throw :abort }

        result = application_form.submit_application

        expect(result).to be false
        expect(application_form.status).to eq("in_progress")
        expect(application_form.submitted_at).to be_nil
      end

      it "handles multiple before_submit callbacks in order" do
        execution_order = []
        TestApplicationForm.set_callback(:submit, :before) { execution_order << "first" }
        TestApplicationForm.set_callback(:submit, :before) { execution_order << "second" }

        application_form.submit_application

        expect(execution_order).to eq([ "first", "second" ])
      end

      it "stops execution when callback throws abort" do
        execution_order = []
        TestApplicationForm.set_callback(:submit, :before) { execution_order << "first" }
        TestApplicationForm.set_callback(:submit, :before) { execution_order << "second"; throw :abort }
        TestApplicationForm.set_callback(:submit, :before) { execution_order << "third" }

        result = application_form.submit_application

        expect(result).to be false
        expect(execution_order).to eq([ "first", "second" ])
        expect(application_form.status).to eq("in_progress")
      end
    end

    describe "submit_application return value" do
      it "returns true when submission is successful" do
        TestApplicationForm.set_callback(:submit, :before) { Rails.logger.debug "Before callback executed" }
        TestApplicationForm.set_callback(:submit, :after) { Rails.logger.debug "After callback executed" }

        result = application_form.submit_application

        expect(result).to be true
        expect(application_form.status).to eq("submitted")
        expect(application_form.submitted_at).to be_present
      end

      it "returns false when before_submit callback aborts submission" do
        TestApplicationForm.set_callback(:submit, :before) { throw :abort }

        result = application_form.submit_application

        expect(result).to be false
        expect(application_form.status).to eq("in_progress")
        expect(application_form.submitted_at).to be_nil
      end
    end

    describe "after_submit callback" do
      it "executes after_submit callback" do
        callback_executed = false
        TestApplicationForm.set_callback(:submit, :after) { callback_executed = true }

        application_form.submit_application

        expect(callback_executed).to be true
        expect(application_form.status).to eq("submitted")
      end

      it "executes after submission is complete" do
        callback_status = nil
        TestApplicationForm.set_callback(:submit, :after) { callback_status = status }

        application_form.submit_application

        expect(callback_status).to eq("submitted")
      end

      it "supports conditional callbacks with if option" do
        callback_executed = false
        TestApplicationForm.set_callback(:submit, :after, if: -> { test_string == "execute" }) { callback_executed = true }

        application_form.test_string = "execute"
        application_form.submit_application

        expect(callback_executed).to be true
      end

      it "skips conditional callbacks when condition is false" do
        callback_executed = false
        TestApplicationForm.set_callback(:submit, :after, if: -> { test_string == "execute" }) { callback_executed = true }

        application_form.test_string = "skip"
        application_form.submit_application

        expect(callback_executed).to be false
        expect(application_form.status).to eq("submitted")
      end

      it "handles multiple after_submit callbacks in reverse order" do
        execution_order = []
        TestApplicationForm.set_callback(:submit, :after) { execution_order << "first" }
        TestApplicationForm.set_callback(:submit, :after) { execution_order << "second" }

        application_form.submit_application

        expect(execution_order).to eq([ "second", "first" ])
      end

      it "does not execute when before_submit callback aborts" do
        callback_executed = false
        TestApplicationForm.set_callback(:submit, :before) { throw :abort }
        TestApplicationForm.set_callback(:submit, :after) { callback_executed = true }

        application_form.submit_application

        expect(callback_executed).to be false
      end
    end

    describe "callback inheritance" do
      it "allows child classes to define their own callbacks" do
        callback_executed = false
        PassportApplicationForm.set_callback(:submit, :before) { callback_executed = true }

        passport_form = PassportApplicationForm.new
        passport_form.name_first = "John"
        passport_form.name_last = "Doe"
        passport_form.date_of_birth = Date.new(1990, 1, 1)
        passport_form.save!

        passport_form.submit_application

        expect(callback_executed).to be true
        expect(passport_form.status).to eq("submitted")
      end

      it "maintains parent class callback functionality in child classes" do
        callback_executed = false
        described_class.set_callback(:submit, :before) { callback_executed = true }

        passport_form = PassportApplicationForm.new
        passport_form.name_first = "John"
        passport_form.name_last = "Doe"
        passport_form.date_of_birth = Date.new(1990, 1, 1)
        passport_form.save!

        passport_form.submit_application

        expect(callback_executed).to be true
        expect(passport_form.status).to eq("submitted")
      end
    end

    describe "error handling in callbacks" do
      it "handles exceptions in before_submit callbacks" do
        TestApplicationForm.set_callback(:submit, :before) { raise StandardError, "Test error" }

        expect { application_form.submit_application }.to raise_error(StandardError, "Test error")
        expect(application_form.status).to eq("in_progress")
      end

      it "handles exceptions in after_submit callbacks" do
        TestApplicationForm.set_callback(:submit, :after) { raise StandardError, "Test error" }

        expect { application_form.submit_application }.to raise_error(StandardError, "Test error")
        expect(application_form.status).to eq("submitted")
      end
    end
  end
end
