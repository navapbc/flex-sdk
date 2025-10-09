# frozen_string_literal: true

require "rails_helper"

RSpec.describe USA::AccordionComponent, type: :component do
  let(:items) do
    [
      { title: "Item 1", content: "<p>Content 1</p>".html_safe, expanded: true },
      { title: "Item 2", content: "<p>Content 2</p>".html_safe, expanded: false }
    ]
  end

  context "with default parameters" do
    it "renders borderless accordion" do
      render_inline(described_class.new(items: items))

      expect(page).to have_css(".usa-accordion")
      expect(page).not_to have_css(".usa-accordion--bordered")
      expect(page).not_to have_css(".usa-accordion--multiselectable")
    end

    it "does not add data-allow-multiple attribute" do
      render_inline(described_class.new(items: items))

      expect(page).not_to have_css("[data-allow-multiple]")
    end
  end

  context "when is_bordered is true" do
    it "adds bordered class" do
      render_inline(described_class.new(items: items, is_bordered: true))

      expect(page).to have_css(".usa-accordion.usa-accordion--bordered")
    end
  end

  context "when is_multiselectable is true" do
    it "adds multiselectable class and attribute" do
      render_inline(described_class.new(items: items, is_multiselectable: true))

      expect(page).to have_css(".usa-accordion.usa-accordion--multiselectable")
      expect(page).to have_css("[data-allow-multiple]")
    end
  end

  it "renders accordion items with correct structure" do
    render_inline(described_class.new(items: items))

    expect(page).to have_css(".usa-accordion__heading", count: 2)
    expect(page).to have_css(".usa-accordion__button", count: 2)
    expect(page).to have_css(".usa-accordion__content", count: 2)
  end

  it "sets aria-expanded based on item expanded state" do
    render_inline(described_class.new(items: items))

    buttons = page.all(".usa-accordion__button")
    expect(buttons[0]["aria-expanded"]).to eq("true")
    expect(buttons[1]["aria-expanded"]).to eq("false")
  end

  it "generates unique IDs for accordion items" do
    render_inline(described_class.new(items: items))

    expect(page).to have_css("#accordion-item-1")
    expect(page).to have_css("#accordion-item-2")
  end

  it "uses custom IDs when provided" do
    custom_items = [
      { title: "Item 1", content: "<p>Content</p>".html_safe, expanded: false, id: "custom-id" }
    ]
    render_inline(described_class.new(items: custom_items))

    expect(page).to have_css("#custom-id")
  end

  it "renders item titles and content" do
    render_inline(described_class.new(items: items))

    expect(page).to have_text("Item 1")
    expect(page).to have_text("Item 2")
    expect(page).to have_css(".usa-accordion__content", text: "Content 1")
    expect(page).to have_css(".usa-accordion__content", text: "Content 2")
  end
end
