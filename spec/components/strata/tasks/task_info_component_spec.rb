# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::Tasks::TaskInfoComponent, type: :component do
  let(:task_info) do
    [
      { label: "Status:",      value: "Pending" },
      { label: "Due On:",      value: "July 01, 2026" },
      { label: "Assigned To:", value: "Jane Doe" }
    ]
  end

  describe "rendering" do
    before { render_inline(described_class.new(task_info: task_info)) }

    it "renders one .grid-col-auto cell per info entry" do
      expect(page).to have_css("div.grid-col-auto", count: task_info.size)
    end

    it "renders each label inside a <strong> tag" do
      task_info.each do |info|
        expect(page).to have_css("strong", text: info[:label])
      end
    end

    it "renders each value alongside its label" do
      task_info.each do |info|
        expect(page).to have_text(info[:value])
      end
    end

    it "wraps the row in the bordered container" do
      expect(page).to have_css("div.border-bottom-1px.margin-bottom-1.padding-bottom-1 .grid-container .grid-row.grid-gap-2")
    end
  end

  describe "with randomized content" do
    let(:task_info) do
      [
        { label: Faker::Alphanumeric.alpha(number: 10), value: Faker::Lorem.sentence },
        { label: Faker::Alphanumeric.alpha(number: 10),
          value: Faker::Date.between(from: 15.days.ago, to: 15.days.from_now).strftime("%B %d, %Y") },
        { label: Faker::Alphanumeric.alpha(number: 5), value: Faker::Name.name }
      ]
    end

    before { render_inline(described_class.new(task_info: task_info)) }

    it "renders each info item correctly" do
      expect(page).to have_css("div.grid-col-auto", count: 3)
      task_info.each do |info|
        expect(page).to have_content(info[:label])
        expect(page).to have_content(info[:value])
      end
    end
  end

  describe "with an empty array" do
    before { render_inline(described_class.new(task_info: [])) }

    it "renders the container but no info cells" do
      expect(page).to have_css("div.border-bottom-1px .grid-row")
      expect(page).to have_no_css("div.grid-col-auto")
    end
  end
end
