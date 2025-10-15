# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::US::AccordionComponent, type: :component do
  def render_accordion(is_bordered: false, is_multiselectable: false, heading_tag: :h2, id_prefix: nil, &block)
    render_inline(described_class.new(
      heading_tag: heading_tag,
      id_prefix: id_prefix,
      is_bordered: is_bordered,
      is_multiselectable: is_multiselectable
    ), &block)
  end

  context "with default parameters" do
    it "renders borderless accordion" do
      render_accordion do |component|
        component.with_heading { "Item 1" }
        component.with_body { "<p>Content 1</p>".html_safe }
        component.with_heading { "Item 2" }
        component.with_body { "<p>Content 2</p>".html_safe }
      end

      expect(page).to have_css(".usa-accordion")
      expect(page).not_to have_css(".usa-accordion--bordered")
      expect(page).not_to have_css(".usa-accordion--multiselectable")
    end

    it "does not add data-allow-multiple attribute" do
      render_accordion do |component|
        component.with_heading { "Item 1" }
        component.with_body { "<p>Content 1</p>".html_safe }
      end

      expect(page).not_to have_css("[data-allow-multiple]")
    end
  end

  context "when is_bordered is true" do
    it "adds bordered class" do
      render_accordion(is_bordered: true) do |component|
        component.with_heading { "Item 1" }
        component.with_body { "<p>Content 1</p>".html_safe }
      end

      expect(page).to have_css(".usa-accordion.usa-accordion--bordered")
    end
  end

  context "when is_multiselectable is true" do
    it "adds multiselectable class and attribute" do
      render_accordion(is_multiselectable: true) do |component|
        component.with_heading { "Item 1" }
        component.with_body { "<p>Content 1</p>".html_safe }
      end

      expect(page).to have_css(".usa-accordion.usa-accordion--multiselectable")
      expect(page).to have_css("[data-allow-multiple]")
    end
  end

  it "renders accordion items with correct structure" do
    render_accordion do |component|
      component.with_heading { "Item 1" }
      component.with_body { "<p>Content 1</p>".html_safe }
      component.with_heading { "Item 2" }
      component.with_body { "<p>Content 2</p>".html_safe }
    end

    expect(page).to have_css(".usa-accordion__heading", count: 2)
    expect(page).to have_css(".usa-accordion__button", count: 2)
    expect(page).to have_css(".usa-accordion__content", count: 2)
  end

  it "sets aria-expanded to false for all buttons" do
    render_accordion do |component|
      component.with_heading { "Item 1" }
      component.with_body { "<p>Content 1</p>".html_safe }
      component.with_heading { "Item 2" }
      component.with_body { "<p>Content 2</p>".html_safe }
    end

    buttons = page.all(".usa-accordion__button")
    expect(buttons[0]["aria-expanded"]).to eq("false")
    expect(buttons[1]["aria-expanded"]).to eq("false")
  end

  it "uses provided ID prefix for accordion items" do
    render_accordion(id_prefix: "custom-") do |component|
      component.with_heading { "Item 1" }
      component.with_body { "<p>Content 1</p>".html_safe }
    end

    expect(page).to have_css("#custom-1")
  end

  it "renders heading titles and content" do
    render_accordion do |component|
      component.with_heading { "Item 1" }
      component.with_body { "<p>Content 1</p>".html_safe }
      component.with_heading { "Item 2" }
      component.with_body { "<p>Content 2</p>".html_safe }
    end

    expect(page).to have_text("Item 1")
    expect(page).to have_text("Item 2")
    expect(page).to have_css(".usa-accordion__content", text: "Content 1")
    expect(page).to have_css(".usa-accordion__content", text: "Content 2")
  end

  it "raises error when headings and bodies counts don't match" do
    expect {
      render_accordion do |component|
        component.with_heading { "Item 1" }
        component.with_body { "<p>Content 1</p>".html_safe }
        component.with_heading { "Item 2" }
      end
    }.to raise_error(ArgumentError, /Number of headings.*must match number of bodies/)
  end
end
