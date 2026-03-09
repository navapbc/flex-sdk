# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "passport_application_forms/edit.html.erb", type: :view do
  let(:passport_application_form) { create(:passport_application_form, :base) }

  it "renders the edit form" do
    assign(:passport_application_form, passport_application_form)
    render

    expect(rendered).to have_selector("form")
  end
end
