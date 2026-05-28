# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::US::ButtonComponent, type: :component do
  describe "default render" do
    it "renders a <button type='button'> with the base usa-button class" do
      render_inline(described_class.new) { "Submit" }

      expect(page).to have_css("button[type='button'].usa-button", text: "Submit")
    end

    it "does not add any variant modifier classes by default" do
      render_inline(described_class.new) { "Submit" }

      expect(page).not_to have_css(".usa-button--secondary")
      expect(page).not_to have_css(".usa-button--accent-cool")
      expect(page).not_to have_css(".usa-button--accent-warm")
      expect(page).not_to have_css(".usa-button--base")
      expect(page).not_to have_css(".usa-button--outline")
      expect(page).not_to have_css(".usa-button--unstyled")
      expect(page).not_to have_css(".usa-button--big")
      expect(page).not_to have_css(".usa-button--inverse")
    end

    it "renders no disabled attribute by default" do
      render_inline(described_class.new) { "Submit" }

      expect(page).not_to have_css("button[disabled]")
      expect(page).not_to have_css("button[aria-disabled]")
    end
  end

  describe "variant" do
    {
      secondary: "usa-button--secondary",
      accent_cool: "usa-button--accent-cool",
      accent_warm: "usa-button--accent-warm",
      base: "usa-button--base",
      outline: "usa-button--outline",
      unstyled: "usa-button--unstyled"
    }.each do |variant, css_class|
      it "adds #{css_class} for variant: #{variant.inspect}" do
        render_inline(described_class.new(variant: variant)) { "Action" }
        expect(page).to have_css("button.usa-button.#{css_class}", text: "Action")
      end
    end

    it "raises ArgumentError when variant is not one of the allowed symbols" do
      expect {
        render_inline(described_class.new(variant: :nonsense)) { "Action" }
      }.to raise_error(ArgumentError, /variant/)
    end

    it "raises ArgumentError when variant is nil" do
      expect {
        render_inline(described_class.new(variant: nil)) { "Action" }
      }.to raise_error(ArgumentError, /variant/)
    end
  end

  describe "size" do
    it "omits the size modifier when size: :default" do
      render_inline(described_class.new(size: :default)) { "Action" }
      expect(page).not_to have_css(".usa-button--big")
    end

    it "adds usa-button--big when size: :big" do
      render_inline(described_class.new(size: :big)) { "Action" }
      expect(page).to have_css("button.usa-button.usa-button--big", text: "Action")
    end

    it "raises ArgumentError on an unknown size" do
      expect {
        render_inline(described_class.new(size: :huge)) { "Action" }
      }.to raise_error(ArgumentError, /size/)
    end
  end

  describe "inverse" do
    it "omits usa-button--inverse by default" do
      render_inline(described_class.new(variant: :outline)) { "Action" }
      expect(page).not_to have_css(".usa-button--inverse")
    end

    it "adds usa-button--inverse when inverse: true" do
      render_inline(described_class.new(variant: :outline, inverse: true)) { "Action" }
      expect(page).to have_css("button.usa-button.usa-button--outline.usa-button--inverse", text: "Action")
    end
  end

  describe "type" do
    it "renders type='button' by default" do
      render_inline(described_class.new) { "X" }
      expect(page).to have_css("button[type='button']")
    end

    it "renders type='submit' when type: :submit" do
      render_inline(described_class.new(type: :submit)) { "Save" }
      expect(page).to have_css("button[type='submit']", text: "Save")
    end

    it "renders type='reset' when type: :reset" do
      render_inline(described_class.new(type: :reset)) { "Reset" }
      expect(page).to have_css("button[type='reset']", text: "Reset")
    end
  end

  describe "href (link-styled button)" do
    it "renders an <a> instead of a <button> when href is set" do
      render_inline(described_class.new(href: "/edit")) { "Edit" }

      expect(page).to have_css("a.usa-button[href='/edit']", text: "Edit")
      expect(page).not_to have_css("button")
    end

    it "does not set a type attribute on the anchor" do
      render_inline(described_class.new(href: "/edit", type: :submit)) { "Edit" }
      expect(page).not_to have_css("a[type]")
    end

    it "propagates variants and sizes onto the anchor" do
      render_inline(described_class.new(href: "/edit", variant: :outline, size: :big)) { "Edit" }
      expect(page).to have_css("a.usa-button.usa-button--outline.usa-button--big[href='/edit']", text: "Edit")
    end
  end

  describe "disabled" do
    it "adds the disabled attribute to a <button>" do
      render_inline(described_class.new(disabled: true)) { "Save" }
      expect(page).to have_css("button[disabled]", text: "Save")
      expect(page).not_to have_css("button[aria-disabled]")
    end

    it "adds aria-disabled='true' to an <a> but does not remove the href" do
      render_inline(described_class.new(href: "/edit", disabled: true)) { "Edit" }
      expect(page).to have_css("a.usa-button[href='/edit'][aria-disabled='true']", text: "Edit")
      expect(page).not_to have_css("a[disabled]")
    end
  end

  describe "extra classes & html attributes" do
    it "appends classes after the USWDS classes" do
      render_inline(described_class.new(classes: "margin-top-2 extra")) { "Action" }

      expect(page).to have_css("button.usa-button.margin-top-2.extra", text: "Action")
    end

    it "forwards id, data-*, and aria-* attributes to the button" do
      render_inline(described_class.new(
        id: "my-btn",
        data: { test: "yes" },
        "aria-label": "click me"
      )) { "Action" }

      expect(page).to have_css("button#my-btn[data-test='yes'][aria-label='click me']")
    end

    it "forwards html attributes to the anchor when href is set" do
      render_inline(described_class.new(href: "/edit", id: "edit-link", data: { turbo: "false" })) { "Edit" }

      expect(page).to have_css("a#edit-link[href='/edit'][data-turbo='false']", text: "Edit")
    end

    it "prefers the dedicated classes: keyword when html_attributes also carries :class" do
      render_inline(described_class.new(classes: "from-classes", class: "from-html-attrs")) { "Action" }

      expect(page).to have_css("button.usa-button.from-classes")
      expect(page).not_to have_css("button.from-html-attrs")
    end
  end

  describe "content block" do
    it "escapes plain text content" do
      render_inline(described_class.new) { "<script>alert(1)</script>" }

      html = page.native.to_html
      expect(html).not_to include("<script>alert(1)</script>")
      expect(html).to include("&lt;script&gt;")
    end

    it "renders html_safe content as HTML" do
      render_inline(described_class.new) { "<strong>Save</strong>".html_safe }

      expect(page).to have_css("button strong", text: "Save")
    end
  end

  describe ".css_classes" do
    it "returns just 'usa-button' for defaults" do
      expect(described_class.css_classes).to eq("usa-button")
    end

    it "includes the variant modifier" do
      expect(described_class.css_classes(variant: :secondary)).to eq("usa-button usa-button--secondary")
    end

    it "includes the size modifier" do
      expect(described_class.css_classes(size: :big)).to eq("usa-button usa-button--big")
    end

    it "includes usa-button--inverse when inverse: true" do
      expect(described_class.css_classes(variant: :outline, inverse: true))
        .to eq("usa-button usa-button--outline usa-button--inverse")
    end

    it "combines variant, size, and inverse in a stable order" do
      expect(described_class.css_classes(variant: :outline, size: :big, inverse: true))
        .to eq("usa-button usa-button--outline usa-button--big usa-button--inverse")
    end

    it "raises ArgumentError on an unknown variant" do
      expect { described_class.css_classes(variant: :nonsense) }
        .to raise_error(ArgumentError, /variant/)
    end

    it "raises ArgumentError on an unknown size" do
      expect { described_class.css_classes(size: :huge) }
        .to raise_error(ArgumentError, /size/)
    end
  end
end
