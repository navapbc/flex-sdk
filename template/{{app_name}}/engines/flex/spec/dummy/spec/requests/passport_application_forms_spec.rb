require 'rails_helper'

RSpec.describe "PassportApplicationForms", type: :request do
  describe "GET /passport_application_forms" do
    it "returns http success" do
      get "/passport_application_forms"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /passport_application_forms/:id" do
    let(:passport_application_form) { PassportApplicationForm.create!(first_name: "John", last_name: "Doe", date_of_birth: Date.new(1990, 1, 1)) }

    it "returns http success" do
      get "/passport_application_forms/#{passport_application_form.id}"
      expect(response).to have_http_status(:success)
    end
  end
end
