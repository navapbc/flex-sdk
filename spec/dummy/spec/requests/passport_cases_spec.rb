require 'rails_helper'

RSpec.describe "PassportCases", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/passport_cases"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    let(:application_form) { PassportApplicationForm.create! }
    let(:kase) { PassportCase.find_by(application_form_id: application_form.id) }

    it "returns http success" do
      get "/passport_cases/#{kase.id}"
      expect(response).to have_http_status(:success)
    end

    it "returns redirects if case not found" do
      get "/passport_cases/00000000"
      expect(response).to have_http_status(:not_found)
    end
  end
end
