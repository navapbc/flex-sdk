# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::Tasks::TaskRowComponent, type: :component do
  let(:task) { create(:strata_task, :with_due_on) }

  before do
    vc_test_controller.request.path_parameters[:controller] = "tasks"
    vc_test_controller.request.path_parameters[:action] = "index"
    render_inline(described_class.new(task: task))
  end

  it "renders a cell per default column" do
    expect(page).to have_css("td", count: described_class.columns.size)
  end

  it "renders the case id" do
    expect(page).to have_text(task.case_id)
  end
end
