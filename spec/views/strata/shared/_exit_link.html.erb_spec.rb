# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "strata/shared/_exit_link.html.erb", type: :view do
  before do
    render partial: "strata/shared/exit_link", locals: { exit_path: exit_path, exit_text: exit_text }
  end

  let(:exit_path) { "/applications" }
  let(:exit_text) { "Exit application" }

  it "renders a link to the exit path" do
    expect(rendered).to have_selector('a.usa-link[href="/applications"]')
  end

  it "displays the exit text" do
    expect(rendered).to have_selector("a.usa-link", text: "Exit application")
  end

  it "renders a back arrow icon" do
    expect(rendered).to have_selector('svg.usa-icon[aria-hidden="true"][focusable="false"][role="img"]')
    expect(rendered).to include("arrow_back")
  end
end
