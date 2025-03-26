require "rails_helper"
# require_relative "../../../app/models/flex/application_form" # File.expand_path('../../../app/models/flex/application_form.rb', __FILE__)
# require File.expand_path('../../../../app/models/flex/application_form', __FILE__)

module Flex
  # Using PassportApplicationForm to test the ApplicationForm abstract class
  RSpec.describe PassportApplicationForm do
    describe "validations" do
      let(:application_form) { described_class.new }

      def generate_random_date_of_birth
        rand(100.years.ago..1.day.ago).to_date
      end

      context "when attempting to update status" do
        before do
          application_form.first_name = "John"
          application_form.last_name = "Doe"
          application_form.date_of_birth = generate_random_date_of_birth
          application_form.save
        end

        it "prevents direct status updates when setting status directly" do
          expect { application_form.status = "submitted" }.to raise_error(NoMethodError)
        end

        it "prevents direct status updates when calling update method" do
          expect { application_form.update(status: "submitted") }.to raise_error(NoMethodError)
        end
      end

      context "when form is in progress" do
        before do
          application_form.first_name = "John"
          application_form.last_name = "Doe"
          application_form.date_of_birth = generate_random_date_of_birth
          application_form.save
        end

        it "defaults to in progress" do
          expect(application_form.status).to eq("in_progress")
        end

        it "allows changes to status" do
          expect(application_form.submit_application).to be true
          expect(application_form.status).to eq("submitted")
        end

        it "allows changes to attributes" do
          expect(application_form.update(first_name: "Jane", last_name: "Smith")).to be true
          expect(application_form.first_name).to eq("Jane")
          expect(application_form.last_name).to eq("Smith")
        end
      end

      context "when form is already submitted" do
        before do
          application_form.first_name = "John"
          application_form.last_name = "Doe"
          application_form.date_of_birth = generate_random_date_of_birth
          application_form.submit_application
        end

        it "prevents changes to attributes" do
          expect(application_form.update(first_name: "Jane", last_name: "Smith")).to be(false)
          expect(application_form.errors[:base]).to include('Cannot modify a submitted application')
          expect(application_form.reload.first_name).to eq("John")
          expect(application_form.reload.last_name).to eq("Doe")
        end
      end
    end
  end
end
