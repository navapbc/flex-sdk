require "rails_helper"

module Flex
  # Using TestExclusionForm to test the ApplicationForm abstract class
  RSpec.describe TestExclusionForm do
    describe "validations" do
      let(:application_form) { described_class.new }

      context "when form is in progress" do
        before do
          application_form.business_name = "Test Business"
          application_form.business_type = "Restaurant"
          application_form.status = :in_progress
          application_form.save
        end

        it "allows changes to status" do
          expect(application_form.submit_form).to be true
          expect(application_form.reload.status).to eq("submitted")
        end

        it "allows changes to attributes" do
          expect(application_form.update(business_name: "Test Cat Cafe", business_type: "Coffee Shop")).to be true
          expect(application_form.reload.business_name).to eq("Test Cat Cafe")
          expect(application_form.reload.business_type).to eq("Coffee Shop")
        end
      end

      context "when form is already submitted" do
        before do
          application_form.business_name = "Test Business"
          application_form.business_type = "Restaurant"
          application_form.submit_form
        end

        it "prevents changes to status" do
          expect(application_form.update(status: :in_progress)).to be false
          expect(application_form.errors[:base]).to include('Cannot modify a submitted application')
          expect(application_form.reload.status).to eq("submitted")
        end

        it "prevents changes to attributes" do
          expect(application_form.update(business_name: "New Business", business_type: "Hobby Store")).to be false
          expect(application_form.errors[:base]).to include('Cannot modify a submitted application')
          expect(application_form.reload.business_name).to eq("Test Business")
          expect(application_form.reload.business_type).to eq("Restaurant")
        end
      end
    end
  end
end
