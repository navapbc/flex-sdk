# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SampleApplicationFormsController do
  render_views
  let(:application) { create(:sample_application_form) }


  describe "GET #edit" do
    it "renders the form" do
      get :edit_name, params: { id: application.id, locale: 'en' }

      expect(response.body).to have_selector("h2", text: /What's your name?/i)
      expect(response.body).to have_field("sample_application_form[applicant_name_first]")
    end
  end

  describe "PATCH #update" do
    context "with required params" do
      let(:valid_params) do
        {
          id: application.id,
          sample_application_form: {
            applicant_name_first: "First"
          },
          locale: "en"
        }
      end

      it "updates the application and redirects to the next page" do
        patch :update_name, params: valid_params
        application.reload

        expect(application.applicant_name_first).to eq("First")
        expect(response).to redirect_to(edit_date_of_birth_sample_application_form_path(application))
      end
    end

    context "with invalid params" do
      let(:invalid_params) do
        {
          id: application.id,
          sample_application_form: {
            applicant_name_first: ""
          },
          locale: "en"
        }
      end

      it "does not update the application" do
        expect {
          patch :update_name, params: invalid_params
        }.not_to change { application.reload.attributes }
      end

      it "renders the form again" do
        patch :update_name, params: invalid_params
        expect(response.body).to have_field("sample_application_form[applicant_name_first]")
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
