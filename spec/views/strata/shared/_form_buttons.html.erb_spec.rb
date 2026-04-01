# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "strata/shared/_form_buttons.html.erb", type: :view do
  let(:back_path) { "/applications" }
  let(:form_builder) do
    ActionView::Helpers::FormBuilder.new(:test, nil, view, {})
  end

  before do
    render partial: "strata/shared/form_buttons", locals: { back_path: back_path, f: form_builder }
  end

  it "renders a back link" do
    expect(rendered).to have_selector('a.usa-button.usa-button--outline[href="/applications"]')
  end

  it "renders a submit button" do
    expect(rendered).to have_selector('input[type="submit"]')
  end

  it "wraps buttons in a button group" do
    expect(rendered).to have_selector("ul.usa-button-group")
  end
end
