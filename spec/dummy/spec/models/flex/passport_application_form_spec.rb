require "rails_helper"
require "support/matchers/publish_event_with_payload"

module Flex
  RSpec.describe PassportApplicationForm do
    describe "validations" do
      let(:passport_application_form) { described_class.new }

      def generate_random_date_of_birth
        rand(100.years.ago..1.day.ago).to_date
      end

      before do
        passport_application_form.first_name = "John"
        passport_application_form.last_name = "Doe"
        passport_application_form.date_of_birth = generate_random_date_of_birth
        passport_application_form.save!
      end

      describe "saving and loading" do
        it "saves the form with valid attributes" do
          expect(passport_application_form).to be_valid
          expect(passport_application_form).to be_persisted
        end

        it "loads the form with correct attributes" do
          loaded_form = described_class.find(passport_application_form.id)
          expect(loaded_form.first_name).to eq("John")
          expect(loaded_form.last_name).to eq("Doe")
          expect(loaded_form.date_of_birth).to eq(passport_application_form.date_of_birth)
        end
      end

      context "when attempting to update case_id" do
        it "prevents direct status updates when setting status directly" do
          expect { passport_application_form.case_id = 22 }.to raise_error(NoMethodError)
        end

        it "prevents direct status updates when calling update method" do
          expect { passport_application_form.update(case_id: 341) }.to raise_error(NoMethodError)
        end
      end

      context "when submitting a form" do
        it "triggers PassportApplicationFormSubmitted event" do
          expected_payload = { application_form_id: passport_application_form.id }
          expect { passport_application_form.submit_application }.to publish_event_with_payload("PassportApplicationFormSubmitted", expected_payload)
        end
      end
    end
  end
end
