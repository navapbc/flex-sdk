# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "passport_application_forms/index.html.erb", type: :view do
  let(:passport_application_forms) do
    [
      PassportApplicationForm.create!(
        name_first: "John",
        name_last: "Doe",
        date_of_birth: Date.new(1990, 1, 1),
        created_at: Time.current
      )
    ]
  end

  it "renders passport application forms" do
    assign(:passport_application_forms, passport_application_forms)
    render
    expect(rendered).to match(/passport applications/i)
    expect(rendered).to match(/new application/i)
  end
end
