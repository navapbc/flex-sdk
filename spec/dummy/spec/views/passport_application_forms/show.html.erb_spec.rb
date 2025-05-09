require 'rails_helper'

RSpec.describe "passport_application_forms/show.html.erb", type: :view do
  context "when viewing an in progress passport application form" do
    let(:passport_application_form) do
      PassportApplicationForm.new(
        first_name: "John",
        last_name: "Doe",
        date_of_birth: Date.new(1990, 1, 1),
        created_at: Time.current
      )
    end

    it "displays the passport application form details" do
      assign(:passport_application_form, passport_application_form)
      render

      expect(rendered).to match(/Your application is in progress/i)
    end
  end

  context "when viewing a submitted passport application form" do
    let(:passport_application_form) do
      passport_application_form = PassportApplicationForm.new(
        first_name: "Jane",
        last_name: "Smith",
        date_of_birth: Date.new(1985, 5, 15),
        created_at: Time.current,
      )
      passport_application_form.submit_application
      passport_application_form
    end

    it "displays the submitted passport application form details" do
      assign(:passport_application_form, passport_application_form)
      render

      expect(rendered).to match(/Your request has been received./i)
    end
  end
end
