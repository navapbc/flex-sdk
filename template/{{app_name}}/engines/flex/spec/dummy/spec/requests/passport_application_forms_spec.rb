require 'rails_helper'

RSpec.describe "PassportApplicationForms", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/passport_application_forms/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/passport_application_forms/show"
      expect(response).to have_http_status(:success)
    end
  end
end
