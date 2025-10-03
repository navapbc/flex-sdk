# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "PassportCases", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/staff/passport_cases"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    let!(:passport_case) { PassportCase.create }

    it "returns http success" do
      get "/staff/passport_cases/#{passport_case.id}"
      expect(response).to have_http_status(:success)
    end

    it "returns redirects if case not found" do
      get "/staff/passport_cases/00000000"
      expect(response).to have_http_status(:not_found)
    end
  end
end
