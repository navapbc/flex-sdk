# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::US::BreadcrumbsComponent, type: :component do
  describe "structural markup" do
    it "renders a nav.usa-breadcrumb wrapping an ol.usa-breadcrumb__list" do
      render_inline(described_class.new) do |bc|
        bc.with_item(href: "/") { "Home" }
        bc.with_item { "Current" }
      end

      expect(page).to have_css("nav.usa-breadcrumb > ol.usa-breadcrumb__list")
    end

    it "defaults the nav aria-label to the i18n value for strata.components.us.breadcrumbs.aria_label" do
      render_inline(described_class.new) do |bc|
        bc.with_item { "Current" }
      end

      expected = I18n.t("strata.components.us.breadcrumbs.aria_label")
      expect(page).to have_css("nav.usa-breadcrumb[aria-label='#{expected}']")
    end

    it "renders an empty <ol> when no items are added" do
      render_inline(described_class.new)

      expect(page).to have_css("ol.usa-breadcrumb__list")
      expect(page).not_to have_css("li")
    end
  end

  describe "non-last items with href" do
    it "renders an <a class='usa-breadcrumb__link'> wrapping a <span>" do
      render_inline(described_class.new) do |bc|
        bc.with_item(href: "/home") { "Home" }
        bc.with_item { "Current" }
      end

      expect(page).to have_css(
        "li.usa-breadcrumb__list-item > a.usa-breadcrumb__link[href='/home'] > span",
        text: "Home"
      )
    end

    it "does not mark non-last items as current" do
      render_inline(described_class.new) do |bc|
        bc.with_item(href: "/home") { "Home" }
        bc.with_item { "Current" }
      end

      expect(page).not_to have_css("li.usa-breadcrumb__list-item.usa-current", text: "Home")
    end
  end

  describe "non-last item without href" do
    it "renders a <span> only, no <a>" do
      render_inline(described_class.new) do |bc|
        bc.with_item { "No link" }
        bc.with_item { "Current" }
      end

      expect(page).to have_css("li.usa-breadcrumb__list-item > span", text: "No link")
      expect(page).not_to have_css("a.usa-breadcrumb__link", text: "No link")
    end
  end

  describe "the last item (current page)" do
    it "renders li.usa-current[aria-current=page] with a <span> child" do
      render_inline(described_class.new) do |bc|
        bc.with_item(href: "/") { "Home" }
        bc.with_item { "Current" }
      end

      expect(page).to have_css(
        "li.usa-breadcrumb__list-item.usa-current[aria-current='page'] > span",
        text: "Current"
      )
    end

    it "never renders an <a> on the last item, even if href is provided" do
      render_inline(described_class.new) do |bc|
        bc.with_item(href: "/") { "Home" }
        bc.with_item(href: "/current") { "Current" }
      end

      expect(page).to have_css("li.usa-current[aria-current='page'] > span", text: "Current")
      expect(page).not_to have_css("li.usa-current a")
    end

    it "renders a single item as the current page (no link, marked current)" do
      render_inline(described_class.new) do |bc|
        bc.with_item(href: "/current") { "Only" }
      end

      expect(page).to have_css("li.usa-breadcrumb__list-item.usa-current[aria-current='page'] > span", text: "Only")
      expect(page).not_to have_css("a")
    end
  end

  describe "wrap variant" do
    it "does not add usa-breadcrumb--wrap by default" do
      render_inline(described_class.new) { |bc| bc.with_item { "Current" } }

      expect(page).not_to have_css(".usa-breadcrumb--wrap")
    end

    it "adds usa-breadcrumb--wrap when wrap: true" do
      render_inline(described_class.new(wrap: true)) { |bc| bc.with_item { "Current" } }

      expect(page).to have_css("nav.usa-breadcrumb.usa-breadcrumb--wrap")
    end
  end

  describe "aria_label override" do
    it "forwards a custom aria_label to the nav" do
      render_inline(described_class.new(aria_label: "Migajas de pan")) do |bc|
        bc.with_item { "Inicio" }
      end

      expect(page).to have_css("nav.usa-breadcrumb[aria-label='Migajas de pan']")
    end
  end

  describe "extra classes & html attributes on the nav" do
    it "appends extra classes after the USWDS classes" do
      render_inline(described_class.new(classes: "margin-top-2 extra")) do |bc|
        bc.with_item { "Current" }
      end

      expect(page).to have_css("nav.usa-breadcrumb.margin-top-2.extra")
    end

    it "forwards id, data-*, and other html attributes to the nav" do
      render_inline(described_class.new(id: "my-bc", data: { test: "yes" })) do |bc|
        bc.with_item { "Current" }
      end

      expect(page).to have_css("nav.usa-breadcrumb#my-bc[data-test='yes']")
    end

    it "does not raise and prefers the dedicated classes: when html_attributes also carries :class" do
      render_inline(described_class.new(classes: "from-classes", class: "from-html-attrs")) do |bc|
        bc.with_item { "Current" }
      end

      expect(page).to have_css("nav.usa-breadcrumb.from-classes")
      expect(page).not_to have_css("nav.from-html-attrs")
    end

    it "does not raise and prefers the dedicated aria_label: when html_attributes also carries :\"aria-label\"" do
      render_inline(described_class.new(aria_label: "Dedicated", "aria-label": "From html attrs")) do |bc|
        bc.with_item { "Current" }
      end

      expect(page).to have_css("nav.usa-breadcrumb[aria-label='Dedicated']")
    end
  end

  describe "item-level options" do
    it "applies item-level classes to the <li>" do
      render_inline(described_class.new) do |bc|
        bc.with_item(href: "/", classes: "highlighted") { "Home" }
        bc.with_item { "Current" }
      end

      expect(page).to have_css("li.usa-breadcrumb__list-item.highlighted", text: "Home")
    end

    it "forwards item-level html attributes to the <li>" do
      render_inline(described_class.new) do |bc|
        bc.with_item(href: "/", id: "crumb-1", data: { index: "1" }) { "Home" }
        bc.with_item { "Current" }
      end

      expect(page).to have_css("li#crumb-1[data-index='1']", text: "Home")
    end
  end

  describe "collection passing via with_items" do
    it "renders one item per element from an array of hashes" do
      render_inline(described_class.new) do |bc|
        bc.with_items([
          { text: "Home", href: "/" },
          { text: "Cases", href: "/cases" },
          { text: "Case #12345" }
        ])
      end

      expect(page).to have_css("li.usa-breadcrumb__list-item", count: 3)
      expect(page).to have_css("a.usa-breadcrumb__link[href='/'] > span", text: "Home")
      expect(page).to have_css("a.usa-breadcrumb__link[href='/cases'] > span", text: "Cases")
      expect(page).to have_css("li.usa-current[aria-current='page'] > span", text: "Case #12345")
    end

    it "can be combined with with_item calls" do
      render_inline(described_class.new) do |bc|
        bc.with_items([ { text: "Home", href: "/" } ])
        bc.with_item(href: "/cases") { "Cases" }
        bc.with_item { "Current" }
      end

      expect(page).to have_css("li", count: 3)
      expect(page).to have_css("a[href='/'] > span", text: "Home")
      expect(page).to have_css("a[href='/cases'] > span", text: "Cases")
      expect(page).to have_css("li.usa-current > span", text: "Current")
    end

    it "renders nothing extra when given an empty collection" do
      render_inline(described_class.new) do |bc|
        bc.with_items([])
      end

      expect(page).to have_css("ol.usa-breadcrumb__list")
      expect(page).not_to have_css("li")
    end
  end

  describe "XSS safety" do
    it "escapes HTML in item text supplied via with_item block" do
      render_inline(described_class.new) do |bc|
        bc.with_item(href: "/") { "<script>alert(1)</script>" }
        bc.with_item { "<img src=x onerror=1>" }
      end

      html = page.native.to_html
      expect(html).not_to include("<script>alert(1)</script>")
      expect(html).not_to include("<img src=x onerror=1>")
      expect(html).to include("&lt;script&gt;")
      expect(html).to include("&lt;img src=x onerror=1&gt;")
    end

    it "escapes HTML in item text supplied via with_items collection" do
      render_inline(described_class.new) do |bc|
        bc.with_items([
          { text: "<script>x</script>", href: "/" },
          { text: "<b>also escaped</b>" }
        ])
      end

      html = page.native.to_html
      expect(html).not_to include("<script>x</script>")
      expect(html).to include("&lt;script&gt;")
      expect(html).to include("&lt;b&gt;also escaped&lt;/b&gt;")
    end
  end

  describe "i18n" do
    it "uses the Spanish translation when I18n.locale is :'es-US'" do
      I18n.with_locale(:"es-US") do
        render_inline(described_class.new) { |bc| bc.with_item { "Inicio" } }
      end

      expected = I18n.t("strata.components.us.breadcrumbs.aria_label", locale: :"es-US")
      expect(page).to have_css("nav.usa-breadcrumb[aria-label='#{expected}']")
    end
  end
end
