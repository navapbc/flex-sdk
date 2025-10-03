# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::Cases::IndexComponent, type: :component do
  let(:cases) { [] }
  let(:base_params) { {
    cases: cases,
    model_class: PassportCase,
    title: "Passport Cases"
  } }
  let(:params) { base_params }

  before do
    render_inline(described_class.new(**params))
  end

  describe "tab navigation" do
    it "renders Open tab" do
      expect(page).to have_link("Open")
    end

    it "renders Closed tab" do
      expect(page).to have_link("Closed")
    end
  end

  describe "with empty cases" do
    let(:cases) { [] }

    it "renders empty state message" do
      expect(page).to have_text("No cases")
    end
  end

  describe "custom case_row_component_class functionality" do
    let(:cases) { [ build(:passport_case) ] }
    let(:params) { base_params.merge(case_row_component_class: Strata::PassportCases::CaseRowComponent) }

    it "renders the custom case row content" do
      expect(page).to have_text("Passport Case ID: #{cases.first.passport_id}")
    end
  end

  describe "without custom case_row_component_class" do
    let(:cases) { [ create(:passport_case) ] }

    it "renders the default case row content" do
      expect(page).to have_text(cases.first.id)
      expect(page).to have_text(cases.first.created_at.strftime('%m/%d/%Y'))
    end
  end
end
