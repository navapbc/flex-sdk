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
end
