# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::LinksHelper, type: :helper do
  describe "#strata_link_to" do
    context "without :as (passthrough mode)" do
      it "renders a plain <a> with no extra classes" do
        result = helper.strata_link_to("Read more", "/articles/1")

        expect(result).to have_element(:a, href: "/articles/1", text: "Read more")
        expect(result).not_to have_css("a.usa-button")
      end

      it "forwards arbitrary html_options to link_to (class, id, data-*)" do
        result = helper.strata_link_to(
          "Read more",
          "/articles/1",
          class: "custom-link",
          id: "article-link",
          data: { turbo: "false" }
        )

        expect(result).to have_element(
          :a,
          href: "/articles/1",
          class: "custom-link",
          id: "article-link",
          "data-turbo": "false"
        )
      end

      it "supports the block form (url + block, no body)" do
        result = helper.strata_link_to("/edit") { "Edit me" }

        expect(result).to have_element(:a, href: "/edit", text: "Edit me")
        expect(result).not_to have_css("a.usa-button")
      end

      it "raises ArgumentError when :variant is passed without `as: :button`" do
        expect { helper.strata_link_to("X", "/x", variant: :outline) }
          .to raise_error(ArgumentError, /as: :button/)
      end

      it "raises ArgumentError when :size is passed without `as: :button`" do
        expect { helper.strata_link_to("X", "/x", size: :big) }
          .to raise_error(ArgumentError, /as: :button/)
      end

      it "raises ArgumentError when :inverse is passed without `as: :button`" do
        expect { helper.strata_link_to("X", "/x", inverse: true) }
          .to raise_error(ArgumentError, /as: :button/)
      end
    end

    context "with `as: :button`" do
      it "renders an <a> with the usa-button class" do
        result = helper.strata_link_to("Edit", "/edit", as: :button)

        expect(result).to have_element(:a, href: "/edit", class: "usa-button", text: "Edit")
      end

      it "applies the variant modifier" do
        result = helper.strata_link_to("Cancel", "/cancel", as: :button, variant: :outline)

        expect(result).to have_element(:a, class: "usa-button usa-button--outline", text: "Cancel")
      end

      it "applies the size modifier" do
        result = helper.strata_link_to("Apply", "/apply", as: :button, size: :big)

        expect(result).to have_element(:a, class: "usa-button usa-button--big")
      end

      it "applies the inverse modifier" do
        result = helper.strata_link_to("Edit", "/edit", as: :button, variant: :outline, inverse: true)

        expect(result).to have_element(:a, class: "usa-button usa-button--outline usa-button--inverse")
      end

      it "merges a user-provided :class with the button classes" do
        result = helper.strata_link_to(
          "Edit",
          "/edit",
          as: :button,
          variant: :outline,
          class: "margin-top-4"
        )

        expect(result).to have_element(:a, class: "usa-button usa-button--outline margin-top-4")
      end

      it "forwards arbitrary html_options to link_to (id, data-*, aria-*)" do
        result = helper.strata_link_to(
          "Edit",
          "/edit",
          as: :button,
          id: "edit-link",
          data: { turbo: "false" },
          "aria-label": "Edit item"
        )

        expect(result).to have_element(:a, id: "edit-link", "data-turbo": "false", "aria-label": "Edit item")
      end

      it "supports the block form" do
        result = helper.strata_link_to("/edit", as: :button, variant: :outline) { "Edit me" }

        expect(result).to have_element(:a, href: "/edit", class: "usa-button usa-button--outline", text: "Edit me")
      end

      it "raises ArgumentError on an unknown variant" do
        expect { helper.strata_link_to("X", "/x", as: :button, variant: :nonsense) }
          .to raise_error(ArgumentError, /variant/)
      end
    end

    context "with `as: :external`" do
      it "renders an <a> with the usa-link and usa-link--external classes" do
        result = helper.strata_link_to("Example", "https://example.gov", as: :external)

        expect(result).to have_element(
          :a,
          href: "https://example.gov",
          class: "usa-link usa-link--external",
          text: "Example"
        )
      end

      it "adds usa-link--alt when alt: true" do
        result = helper.strata_link_to("Example", "https://example.gov", as: :external, alt: true)

        expect(result).to have_element(
          :a,
          class: "usa-link usa-link--external usa-link--alt"
        )
      end

      it "does not auto-set target or rel" do
        result = helper.strata_link_to("Example", "https://example.gov", as: :external)

        expect(result).not_to have_css("a[target]")
        expect(result).not_to have_css("a[rel]")
      end

      it "forwards an explicit target and rel from the caller" do
        result = helper.strata_link_to(
          "Example",
          "https://example.gov",
          as: :external,
          target: "_blank",
          rel: "noopener noreferrer"
        )

        expect(result).to have_element(
          :a,
          target: "_blank",
          rel: "noopener noreferrer"
        )
      end

      it "merges a user-provided :class with the link classes" do
        result = helper.strata_link_to(
          "Example",
          "https://example.gov",
          as: :external,
          class: "margin-top-4"
        )

        expect(result).to have_element(:a, class: "usa-link usa-link--external margin-top-4")
      end

      it "forwards arbitrary html_options to link_to (id, data-*, aria-*)" do
        result = helper.strata_link_to(
          "Example",
          "https://example.gov",
          as: :external,
          id: "example-link",
          data: { turbo: "false" },
          "aria-label": "Visit example.gov"
        )

        expect(result).to have_element(
          :a,
          id: "example-link",
          "data-turbo": "false",
          "aria-label": "Visit example.gov"
        )
      end

      it "supports the block form" do
        result = helper.strata_link_to("https://example.gov", as: :external) { "Example" }

        expect(result).to have_element(
          :a,
          href: "https://example.gov",
          class: "usa-link usa-link--external",
          text: "Example"
        )
      end
    end

    context "when :alt is passed without `as: :external`" do
      it "silently drops :alt when no :as is given (no error, no stray attribute on the <a>)" do
        result = helper.strata_link_to("Read more", "/articles/1", alt: true)

        expect(result).to have_element(:a, href: "/articles/1", text: "Read more")
        expect(result).not_to have_css("a[alt]")
        expect(result).not_to have_css(".usa-link--alt")
      end
    end

    context "with an unknown :as value" do
      it "raises ArgumentError" do
        expect { helper.strata_link_to("X", "/x", as: :nonsense) }
          .to raise_error(ArgumentError, /:as/)
      end
    end
  end
end
