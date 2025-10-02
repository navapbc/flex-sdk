require 'rails_helper'

RSpec.describe "strata/cases/index.html.erb", type: :view do
  let(:model_class) { PassportCase }
  let(:cases) { [] }
  let(:base_locals) { {
    model_class: model_class
  } }
  let(:locals) { base_locals }

  before do
    assign(:cases, cases)
    render locals: locals
  end

  describe "tab navigation" do
    it "renders Open tab" do
      expect(rendered).to have_link("Open")
    end

    it "renders Closed tab" do
      expect(rendered).to have_link("Closed")
    end
  end

  describe "with empty cases" do
    let(:cases) { [] }

    before { render locals: locals }

    it "renders empty state message" do
      expect(rendered).to have_css('td.text-center[colspan="3"]', text: "No cases")
    end
  end

  describe "custom case_row_view functionality" do
    let(:cases) { [ build(:passport_case) ] }
    let(:locals) { base_locals.merge(case_row_view: 'passport_cases/case_row') }

    it "renders the custom case row content" do
      expect(rendered).to include("Passport Case ID: #{cases.first.passport_id}")
    end
  end

  describe "without custom case_row_view" do
    let(:cases) { [ create(:passport_case) ] }

    it "renders the default case row content" do
      expect(rendered).to include(cases.first.id)
      expect(rendered).to include(cases.first.created_at.strftime('%m/%d/%Y'))
    end
  end
end
