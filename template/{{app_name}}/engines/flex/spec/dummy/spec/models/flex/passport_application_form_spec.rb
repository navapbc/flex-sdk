require "rails_helper"

module Flex
  RSpec.describe PassportApplicationForm do
    describe "validations" do
      let(:passport_application_form) { described_class.new }
      let(:mock_events_manager) { class_double(EventManager) }

      def generate_random_date_of_birth
        rand(100.years.ago..1.day.ago).to_date
      end

      before do
        stub_const("Flex::EventManager", mock_events_manager)
        allow(PassportApplicationBusinessProcessManager.instance)
          .to receive(:business_process)
          .and_return(instance_double(BusinessProcess, execute: true))
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

      describe "memorable_date attribute" do
        it "allows setting a Date" do
          passport_application_form.date_of_birth = Date.new(2020, 1, 1)
          expect(passport_application_form.date_of_birth).to eq("2020-01-01")
        end

        it "allows setting a Hash with year, month, and day" do
          passport_application_form.date_of_birth = { year: 2020, month: 1, day: 1 }
          expect(passport_application_form.date_of_birth).to eq("2020-01-01")
        end

        [
          { year: 2020, month: 1, day: -1 },
          { year: 2020, month: 1, day: 0 },
          { year: 2020, month: 1, day: 32 },
          { year: 2020, month: -1, day: 1 },
          { year: 2020, month: 0, day: 1 },
          { year: 2020, month: 13, day: 1 },
          { year: 2020, month: 2, day: 30 }
        ].each do |date|
          it "validates that date is a valid date" do
            passport_application_form.date_of_birth = date
            expect(passport_application_form.date_of_birth).to eq("%04d-%02d-%02d" % [ date[:year], date[:month], date[:day] ])
            expect(passport_application_form).not_to be_valid
            expect(passport_application_form.errors["date_of_birth"]).to include("is not a valid date")
          end
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
        it "triggers the event when submitting application" do
          allow(mock_events_manager).to receive(:publish)

          passport_application_form.submit_application

          expect(mock_events_manager).to have_received(:publish)
            .with("PassportApplicationFormSubmitted", a_hash_including(case_id: passport_application_form.case_id))
            .once
        end
      end
    end
  end
end
