# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "PassportApplicationForms", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/passport_application_forms"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    let(:passport_application_form) { PassportApplicationForm.create! }

    it "returns http success" do
      get "/passport_application_forms/#{passport_application_form.id}"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    let(:passport_application_form) { PassportApplicationForm.create! }

    it "returns http success" do
      get "/passport_application_forms/#{passport_application_form.id}/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /update" do
    let(:passport_application_form) { PassportApplicationForm.create! }

    it "updates the form and redirects to show" do
      patch "/passport_application_forms/#{passport_application_form.id}",
            params: { passport_application_form: { name_first: "Jane", name_last: "Doe" } }
      expect(response).to redirect_to(passport_application_form_path(passport_application_form))
      expect(passport_application_form.reload.name_first).to eq("Jane")
    end

    it "re-renders edit when update fails" do
      allow(PassportApplicationForm).to receive(:find).and_return(passport_application_form)
      allow(passport_application_form).to receive(:update).and_return(false)
      patch "/passport_application_forms/#{passport_application_form.id}",
            params: { passport_application_form: { name_first: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
