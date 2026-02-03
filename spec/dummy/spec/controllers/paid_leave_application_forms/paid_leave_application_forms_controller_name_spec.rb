# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PaidLeaveApplicationFormsController do
  render_views
  let(:leave_application) { create(:paid_leave_application_form) }


  describe "GET #edit" do
    it "renders the form" do
      get :edit_name, params: { id: leave_application.id, locale: 'en' }

      expect(response.body).to have_selector("h2", text: /What's your name?/i)
      expect(response.body).to have_field("paid_leave_application_form[applicant_name_first]")
    end
  end

  describe "PATCH #update" do
    context "with required params" do
      let(:valid_params) do
        {
          id: leave_application.id,
          paid_leave_application_form: {
            applicant_name_first: "First"
          },
          locale: "en"
        }
      end

      it "updates the leave application and redirects to the next page" do
        patch :update_name, params: valid_params
        leave_application.reload

        expect(leave_application.applicant_name_first).to eq("First")
        expect(response).to redirect_to(edit_date_of_birth_paid_leave_application_form_path(leave_application))
      end
    end

    context "with invalid params" do
      let(:invalid_params) do
        {
          id: leave_application.id,
          paid_leave_application_form: {
            applicant_name_first: ""
          },
          locale: "en"
        }
      end

      it "does not update the leave request" do
        expect {
          patch :update_name, params: invalid_params
        }.not_to change { leave_application.reload.attributes }
      end

      it "renders the form again" do
        patch :update_name, params: invalid_params
        expect(response.body).to have_field("paid_leave_application_form[applicant_name_first]")
      end

      it "sets flash errors" do
        patch :update_name, params: invalid_params
        expect(flash.now[:errors]).to include(/Applicant name first can't be blank/i)
      end

      it "returns unprocessable entity status" do
        patch :update_name, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
