# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "passport_application_forms/show.html.erb", type: :view do
  context "when viewing an in progress passport application form" do
    let(:passport_application_form) { create(:passport_application_form, :base) }

    it "displays the step indicator" do
      assign(:passport_application_form, passport_application_form)
      render

      expect(rendered).to have_selector(".usa-step-indicator")
    end

    it "displays an edit link" do
      assign(:passport_application_form, passport_application_form)
      render

      expect(rendered).to have_link(href: edit_passport_application_form_path(passport_application_form))
    end

    it "displays the applicant name" do
      assign(:passport_application_form, passport_application_form)
      render

      expect(rendered).to include(passport_application_form.name_first)
      expect(rendered).to include(passport_application_form.name_last)
    end

    it "displays the date of birth" do
      assign(:passport_application_form, passport_application_form)
      render

      expect(rendered).to include(passport_application_form.date_of_birth.strftime("%B %-d, %Y"))
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
