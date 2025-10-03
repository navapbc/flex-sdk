# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "passport_application_forms/show.html.erb", type: :view do
  context "when viewing an in progress passport application form" do
    let(:passport_application_form) { create(:passport_application_form, :base) }

    it "displays the passport application form details" do
      assign(:passport_application_form, passport_application_form)
      render

      expect(rendered).to match(/Your application is in progress/i)
    end
  end

  context "when viewing a submitted passport application form" do
    let(:passport_application_form) do
      passport_application_form = build(:passport_application_form, :base)
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
