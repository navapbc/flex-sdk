require "rails_helper"

module Flex
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

        it "allows changes to in progress forms" do
          expect(application_form.update(status: :submitted)).to be true
        end
      end

      context "when form is submitted" do
        before do
          application_form.business_name = "Test Business"
          application_form.business_type = "Restaurant"
          application_form.status = :submitted
          application_form.save
        end

        it "prevents changes to submitted forms" do
          expect(application_form.update(status: :in_progress)).to be false
          expect(application_form.errors[:base]).to include('Cannot modify a submitted application')
        end
      end
    end
  end
end
