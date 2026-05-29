# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::US::ButtonGroupComponent, type: :component do
  describe "structural markup" do
    it "renders a ul.usa-button-group" do
      render_inline(described_class.new) do |group|
        group.with_item { "A" }
      end

      expect(page).to have_css("ul.usa-button-group")
    end

    it "wraps each item in a bare <li> by default (no usa-button-group__item)" do
      render_inline(described_class.new) do |group|
        group.with_item { "A" }
        group.with_item { "B" }
      end

      expect(page).to have_css("ul.usa-button-group > li", count: 2)
      expect(page).to have_css("li", text: "A")
      expect(page).to have_css("li", text: "B")
      expect(page).not_to have_css("li.usa-button-group__item")
    end

    it "renders an empty <ul> when no items are added" do
      render_inline(described_class.new)

      expect(page).to have_css("ul.usa-button-group")
      expect(page).not_to have_css("li")
    end
  end

  describe "segmented variant" do
    it "omits usa-button-group--segmented by default" do
      render_inline(described_class.new) { |group| group.with_item { "A" } }

      expect(page).not_to have_css(".usa-button-group--segmented")
    end

    it "adds usa-button-group--segmented when segmented: true" do
      render_inline(described_class.new(segmented: true)) { |group| group.with_item { "A" } }

      expect(page).to have_css("ul.usa-button-group.usa-button-group--segmented")
    end

    it "adds usa-button-group__item to each <li> only when segmented: true" do
      render_inline(described_class.new(segmented: true)) do |group|
        group.with_item { "A" }
        group.with_item { "B" }
      end

      expect(page).to have_css(
        "ul.usa-button-group--segmented > li.usa-button-group__item",
        count: 2
      )
    end
  end

  describe "extra classes & html attributes" do
    it "appends extra classes after the USWDS classes" do
      render_inline(described_class.new(classes: "margin-top-4 extra")) do |group|
        group.with_item { "A" }
      end

      expect(page).to have_css("ul.usa-button-group.margin-top-4.extra")
    end

    it "forwards id, data-*, and role attributes to the <ul>" do
      render_inline(described_class.new(id: "my-group", data: { test: "yes" }, role: "group")) do |group|
        group.with_item { "A" }
      end

      expect(page).to have_css("ul#my-group[data-test='yes'][role='group']")
    end

    it "prefers the dedicated classes: keyword when html_attributes also carries :class" do
      render_inline(described_class.new(classes: "from-classes", class: "from-html-attrs")) do |group|
        group.with_item { "A" }
      end

      expect(page).to have_css("ul.usa-button-group.from-classes")
      expect(page).not_to have_css("ul.from-html-attrs")
    end
  end

  describe "item-level options" do
    it "applies item-level classes to a bare <li> in the default variant" do
      render_inline(described_class.new) do |group|
        group.with_item(classes: "highlighted") { "A" }
      end

      expect(page).to have_css("li.highlighted", text: "A")
      expect(page).not_to have_css("li.usa-button-group__item")
    end

    it "appends item-level classes after usa-button-group__item when segmented" do
      render_inline(described_class.new(segmented: true)) do |group|
        group.with_item(classes: "highlighted") { "A" }
      end

      expect(page).to have_css("li.usa-button-group__item.highlighted", text: "A")
    end

    it "forwards item-level html attributes to the <li>" do
      render_inline(described_class.new) do |group|
        group.with_item(id: "first-item", data: { index: "0" }) { "A" }
      end

      expect(page).to have_css("li#first-item[data-index='0']", text: "A")
    end
  end

  describe "content inside items" do
    it "renders arbitrary HTML inside items" do
      render_inline(described_class.new) do |group|
        group.with_item { "<a class='usa-button' href='/x'>Go</a>".html_safe }
      end

      expect(page).to have_css("li a.usa-button[href='/x']", text: "Go")
    end

    it "escapes plain string content" do
      render_inline(described_class.new) do |group|
        group.with_item { "<script>alert(1)</script>" }
      end

      html = page.native.to_html
      expect(html).not_to include("<script>alert(1)</script>")
      expect(html).to include("&lt;script&gt;")
    end
  end
end
