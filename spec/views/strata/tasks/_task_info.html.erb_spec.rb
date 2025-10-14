# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "strata/tasks/_task_info.html.erb", type: :view do
  context "when task_info is provided via content_for" do
    let(:custom_label) { Faker::Alphanumeric.alpha(number: 10) }
    let(:custom_value) { Faker::Lorem.sentence }

    before do
      view.content_for(:task_info) do
        "<div class=\"grid-col-auto\"><strong>#{custom_label}</strong> #{custom_value}</div>".html_safe
      end
      render partial: "strata/tasks/task_info"
    end

    it "renders the custom task info content" do
      expect(rendered).to include(custom_label)
      expect(rendered).to include(custom_value)
    end
  end

  context "when task_info local is provided as array of hashes" do
    let(:task_info) do
      [
        { label: Faker::Alphanumeric.alpha(number: 10), value: Faker::Lorem.sentence },
        { label: Faker::Alphanumeric.alpha(number: 10), value: Faker::Date.between(from: 15.days.ago, to: 15.days.from_now).strftime("%B %d, %Y") },
        { label: Faker::Alphanumeric.alpha(number: 5), value: Faker::Name.name }
      ]
    end

    before do
      render partial: "strata/tasks/task_info", locals: { task_info: task_info }
    end

    it "renders each info item correctly" do
      expect(rendered).to have_selector('div.grid-col-auto', count: 3)
      expect(rendered).to include(task_info[0][:label])
      expect(rendered).to include(task_info[0][:value])
      expect(rendered).to include(task_info[1][:label])
      expect(rendered).to include(task_info[1][:value])
      expect(rendered).to include(task_info[2][:label])
      expect(rendered).to include(task_info[2][:value])
    end
  end
end
