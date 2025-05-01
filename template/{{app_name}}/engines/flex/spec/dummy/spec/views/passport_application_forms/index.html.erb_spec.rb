require 'rails_helper'

RSpec.describe "passport_application_forms/index.html.erb", type: :view do
  let(:passport_application_forms) do
    p = PassportApplicationForm.new
    p.first_name = "John"
    p.last_name = "Doe"
    p.date_of_birth = Date.new(1990, 1, 1)
    p.created_at = Time.current
    [ p ]
  end

  it "renders passport application forms" do
    assign(:passport_application_forms, passport_application_forms)
    render
    expect(rendered).to match(/passport applications/i)
    expect(rendered).to match(/new application/i)
  end
end
