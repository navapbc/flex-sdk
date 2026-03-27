# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::Flows::TaskSectionComponent, type: :component do
  let(:flow) { SampleFlow.new(build_stubbed(:sample_application_form)) }
  let(:task) { flow.tasks.first }

  describe "when task dependencies are not met" do
    before do
      allow(task).to receive(:dependencies_met?).and_return(false)
      render_inline(described_class.new(flow:, task:))
    end

    it "renders 'Cannot start yet'" do
      expect(page).to have_text("Cannot start yet")
    end

    it "does not render any links" do
      expect(page).not_to have_link
    end
  end

  describe "when task dependencies are met" do
    before do
      allow(task).to receive(:dependencies_met?).and_return(true)
      render_inline(described_class.new(flow:, task:))
    end

    it "renders a 'Start' link" do
      expect(page).to have_link("Start")
    end

    it "does not render 'Cannot start yet'" do
      expect(page).not_to have_text("Cannot start yet")
    end
  end
end
