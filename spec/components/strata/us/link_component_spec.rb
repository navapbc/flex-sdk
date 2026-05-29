# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::US::LinkComponent, type: :component do
  describe "default render" do
    it "renders an <a> with the base usa-link class" do
      render_inline(described_class.new(href: "/articles/1")) { "Read more" }

      expect(page).to have_css("a.usa-link[href='/articles/1']", text: "Read more")
    end

    it "does not add any modifier classes by default" do
      render_inline(described_class.new(href: "/articles/1")) { "Read more" }

      expect(page).not_to have_css(".usa-link--external")
      expect(page).not_to have_css(".usa-link--alt")
    end

    it "does not set target or rel by default" do
      render_inline(described_class.new(href: "/articles/1")) { "Read more" }

      expect(page).not_to have_css("a[target]")
      expect(page).not_to have_css("a[rel]")
    end
  end

  describe "external" do
    it "adds usa-link--external when external: true" do
      render_inline(described_class.new(href: "https://example.com", external: true)) { "Example" }

      expect(page).to have_css("a.usa-link.usa-link--external[href='https://example.com']", text: "Example")
    end

    it "does not add usa-link--alt when external: true without alt: true" do
      render_inline(described_class.new(href: "https://example.com", external: true)) { "Example" }

      expect(page).not_to have_css(".usa-link--alt")
    end

    it "does not auto-set target or rel when external: true" do
      render_inline(described_class.new(href: "https://example.com", external: true)) { "Example" }

      expect(page).not_to have_css("a[target]")
      expect(page).not_to have_css("a[rel]")
    end
  end

  describe "alt" do
    it "adds usa-link--alt when external: true and alt: true" do
      render_inline(described_class.new(href: "https://example.com", external: true, alt: true)) { "Example" }

      expect(page).to have_css("a.usa-link.usa-link--external.usa-link--alt[href='https://example.com']", text: "Example")
    end

    it "is a no-op when alt: true is passed without external: true" do
      render_inline(described_class.new(href: "/articles/1", alt: true)) { "Read more" }

      expect(page).to have_css("a.usa-link[href='/articles/1']", text: "Read more")
      expect(page).not_to have_css(".usa-link--alt")
      expect(page).not_to have_css(".usa-link--external")
    end
  end

  describe "extra classes & html attributes" do
    it "appends classes after the USWDS classes" do
      render_inline(described_class.new(href: "/x", classes: "margin-top-2 extra")) { "Link" }

      expect(page).to have_css("a.usa-link.margin-top-2.extra", text: "Link")
    end

    it "forwards id, data-*, and aria-* attributes to the anchor" do
      render_inline(described_class.new(
        href: "/x",
        id: "my-link",
        data: { test: "yes" },
        "aria-label": "click me"
      )) { "Link" }

      expect(page).to have_css("a#my-link[data-test='yes'][aria-label='click me']")
    end

    it "forwards target and rel when explicitly set by the caller" do
      render_inline(described_class.new(
        href: "https://example.com",
        external: true,
        target: "_blank",
        rel: "noopener noreferrer"
      )) { "Example" }

      expect(page).to have_css("a.usa-link.usa-link--external[target='_blank'][rel='noopener noreferrer']")
    end

    it "prefers the dedicated classes: keyword when html_attributes also carries :class" do
      render_inline(described_class.new(href: "/x", classes: "from-classes", class: "from-html-attrs")) { "Link" }

      expect(page).to have_css("a.usa-link.from-classes")
      expect(page).not_to have_css("a.from-html-attrs")
    end
  end

  describe "content block" do
    it "escapes plain text content" do
      render_inline(described_class.new(href: "/x")) { "<script>alert(1)</script>" }

      html = page.native.to_html
      expect(html).not_to include("<script>alert(1)</script>")
      expect(html).to include("&lt;script&gt;")
    end

    it "renders html_safe content as HTML" do
      render_inline(described_class.new(href: "/x")) { "<strong>Read more</strong>".html_safe }

      expect(page).to have_css("a strong", text: "Read more")
    end
  end

  describe ".css_classes" do
    it "returns just 'usa-link' for defaults" do
      expect(described_class.css_classes).to eq("usa-link")
    end

    it "includes usa-link--external when external: true" do
      expect(described_class.css_classes(external: true)).to eq("usa-link usa-link--external")
    end

    it "combines external and alt in a stable order" do
      expect(described_class.css_classes(external: true, alt: true))
        .to eq("usa-link usa-link--external usa-link--alt")
    end

    it "ignores alt: true when external: false (no-op)" do
      expect(described_class.css_classes(alt: true)).to eq("usa-link")
    end
  end
end
