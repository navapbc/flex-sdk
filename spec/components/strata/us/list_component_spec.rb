# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::US::ListComponent, type: :component do
  it "renders an unordered list by default" do
    render_inline(described_class.new) do |list|
      list.with_item { "First" }
      list.with_item { "Second" }
    end

    expect(page).to have_css("ul.usa-list")
    expect(page).not_to have_css("ol")
    expect(page).to have_css("ul.usa-list > li", count: 2)
    expect(page).to have_css("li", text: "First")
    expect(page).to have_css("li", text: "Second")
  end

  it "renders an ordered list when ordered: true" do
    render_inline(described_class.new(ordered: true)) do |list|
      list.with_item { "First" }
      list.with_item { "Second" }
    end

    expect(page).to have_css("ol.usa-list")
    expect(page).not_to have_css("ul")
    expect(page).to have_css("ol.usa-list > li", count: 2)
  end

  it "applies the unstyled modifier when unstyled: true" do
    render_inline(described_class.new(unstyled: true)) do |list|
      list.with_item { "First" }
    end

    expect(page).to have_css("ul.usa-list.usa-list--unstyled")
  end

  it "does not apply the unstyled modifier by default" do
    render_inline(described_class.new) do |list|
      list.with_item { "First" }
    end

    expect(page).not_to have_css(".usa-list--unstyled")
  end

  it "combines ordered and unstyled" do
    render_inline(described_class.new(ordered: true, unstyled: true)) do |list|
      list.with_item { "First" }
    end

    expect(page).to have_css("ol.usa-list.usa-list--unstyled")
  end

  it "applies additional classes to the root element" do
    render_inline(described_class.new(classes: "my-extra-class")) do |list|
      list.with_item { "First" }
    end

    expect(page).to have_css("ul.usa-list.my-extra-class")
  end

  it "passes html attributes to the root element" do
    render_inline(described_class.new(id: "my-list", data: { foo: "bar" })) do |list|
      list.with_item { "First" }
    end

    expect(page).to have_css("ul#my-list.usa-list[data-foo='bar']")
  end

  it "applies item-level classes to each li" do
    render_inline(described_class.new) do |list|
      list.with_item(classes: "highlighted") { "First" }
      list.with_item { "Second" }
    end

    expect(page).to have_css("li.highlighted", text: "First")
    expect(page).not_to have_css("li.highlighted", text: "Second")
  end

  it "passes item-level html attributes to each li" do
    render_inline(described_class.new) do |list|
      list.with_item(id: "item-1", data: { index: "1" }) { "First" }
    end

    expect(page).to have_css("li#item-1[data-index='1']", text: "First")
  end

  it "renders empty when no items are added" do
    render_inline(described_class.new)

    expect(page).to have_css("ul.usa-list")
    expect(page).not_to have_css("li")
  end

  describe "collection-passing via with_items" do
    it "renders one li per element when passed an array of strings" do
      items = [ "Apples", "Bananas", "Cherries" ]

      render_inline(described_class.new) do |list|
        list.with_items(items)
      end

      expect(page).to have_css("ul.usa-list > li", count: 3)
      expect(page).to have_css("li", text: "Apples")
      expect(page).to have_css("li", text: "Bananas")
      expect(page).to have_css("li", text: "Cherries")
    end

    it "preserves order of items in the collection" do
      render_inline(described_class.new(ordered: true)) do |list|
        list.with_items([ "One", "Two", "Three" ])
      end

      rendered_text = page.all("li").map(&:text)
      expect(rendered_text).to eq([ "One", "Two", "Three" ])
    end

    it "can be combined with with_item calls" do
      render_inline(described_class.new) do |list|
        list.with_items([ "From array A", "From array B" ])
        list.with_item { "Individual" }
      end

      expect(page).to have_css("li", count: 3)
      expect(page).to have_css("li", text: "From array A")
      expect(page).to have_css("li", text: "From array B")
      expect(page).to have_css("li", text: "Individual")
    end

    it "renders nothing extra when given an empty collection" do
      render_inline(described_class.new) do |list|
        list.with_items([])
      end

      expect(page).to have_css("ul.usa-list")
      expect(page).not_to have_css("li")
    end
  end

  describe "nested lists" do
    it "supports nesting by rendering arbitrary block content inside an item" do
      render_inline(described_class.new) do |outer|
        outer.with_item do
          "Parent item"
        end
      end

      expect(page).to have_css("ul.usa-list > li", text: "Parent item")
    end
  end
end
