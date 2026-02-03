# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PaidLeaveApplicationFormsController do
  render_views

  describe "GET #index" do
    it "renders applications" do
      create(:paid_leave_application_form, applicant_name_first: "Kevin")
      create(:paid_leave_application_form, applicant_name_first: "Mary")
      get :index, params: { locale: "en" }

      expect(response.body).to have_selector("td", text: "Paid Leave Form TODO")
    end
  end

  describe "GET #new" do
    it "renders" do
      get :new, params: { locale: "en" }
      expect(response.body).to have_selector("h1", text: /Begin your leave application/i)
    end
  end

  describe "POST #create" do
    it "creates a new leave application and redirects to the next page" do
      post :create, params: { locale: "en" }
      expect(PaidLeaveApplicationForm.all.length).to eq(1)
      leave_application = PaidLeaveApplicationForm.first
      expect(response).to redirect_to(paid_leave_application_form_path(leave_application))
    end
  end

  describe "GET #review" do
    let(:leave_application) { create(:paid_leave_application_form, :submittable) }
    let(:params) do
      {
        id: leave_application.id,
        locale: "en"
      }
    end

    it "renders leave application details" do
      get :review, params: params
      expect(response.body).to have_selector("h1", text: "Review your application")
      expect(response.body).to have_selector("input[type=submit]")
    end

    context "with a submitted application" do
      it "hides submission buttons" do
        leave_application.submit_application
        get :review, params: params
        expect(response.body).not_to have_selector("input[type=submit]")
      end
    end
  end

  describe "PATCH #submit" do
    let(:params) do
      {
        id: leave_application.id,
        locale: "en"
      }
    end

    context "when the application cannot be submitted" do
      let(:leave_application) { create(:paid_leave_application_form) }

      it "does not update the leave application" do
        expect {
          patch :submit, params: params
        }.not_to change { leave_application.reload.attributes }
      end

      it "renders the review form again" do
        patch :submit, params: params
        expect(response.body).to have_selector("h1", text: "Review your application")
      end

      it "sets flash errors" do
        patch :submit, params: params
        expect(flash.now[:errors]).to include(/Date of birth can't be blank/i)
      end
    end

    context "when the application can be submitted" do
      let(:leave_application) { create(:paid_leave_application_form, :submittable) }

      it "updates the leave application and redirects to the next page" do
        patch :submit, params: params
        leave_application.reload

        expect(leave_application.submitted?).to be(true)
        expect(response).to redirect_to(paid_leave_application_form_path(leave_application))
      end
    end
  end

  describe "GET #show" do
    let(:params) do
      {
        id: leave_application.id,
        locale: "en"
      }
    end


    context "with a submitted application" do
      let(:leave_application) { create(:paid_leave_application_form, :submittable) }

      it "shows the submitted status" do
        leave_application.submit_application
        get :show, params: params
        expect(response.body).to have_selector("p", text: "Submitted")
      end
    end
  end
end
