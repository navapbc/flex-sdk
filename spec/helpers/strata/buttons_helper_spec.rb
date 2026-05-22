# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::ButtonsHelper, type: :helper do
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

    context "with an unknown :as value" do
      it "raises ArgumentError" do
        expect { helper.strata_link_to("X", "/x", as: :nonsense) }
          .to raise_error(ArgumentError, /:as/)
      end
    end
  end

  describe "#strata_button_to" do
    it "renders a <form> wrapping a usa-button-styled <button>" do
      result = helper.strata_button_to("Delete", "/items/1", method: :delete)

      expect(result).to have_element(:form, action: "/items/1")
      expect(result).to have_element(:button, type: "submit", class: "usa-button", text: "Delete")
    end

    it "applies the variant modifier to the <button>" do
      result = helper.strata_button_to("Delete", "/items/1", method: :delete, variant: :secondary)

      expect(result).to have_element(:button, class: "usa-button usa-button--secondary", text: "Delete")
    end

    it "applies the size and inverse modifiers to the <button>" do
      result = helper.strata_button_to("Submit", "/x", size: :big, inverse: true)

      expect(result).to have_element(:button, class: "usa-button usa-button--big usa-button--inverse")
    end

    it "merges a user-provided :class with the button classes" do
      result = helper.strata_button_to("Delete", "/items/1", method: :delete, variant: :secondary, class: "margin-top-2")

      expect(result).to have_element(:button, class: "usa-button usa-button--secondary margin-top-2")
    end

    it "preserves Rails button_to options like :method and :params" do
      result = helper.strata_button_to("Delete", "/items/1", method: :delete, params: { confirm: "yes" })

      # Rails button_to renders the method override and params as hidden inputs on non-GET
      expect(result).to have_css('input[type="hidden"][name="_method"][value="delete"]', visible: :all)
      expect(result).to have_css('input[type="hidden"][name="confirm"][value="yes"]', visible: :all)
    end

    it "raises ArgumentError on an unknown variant" do
      expect { helper.strata_button_to("X", "/x", variant: :nonsense) }
        .to raise_error(ArgumentError, /variant/)
    end

    it "matches ButtonComponent.css_classes for the same keywords" do
      expected = Strata::US::ButtonComponent.css_classes(variant: :outline, size: :big, inverse: true)

      result = helper.strata_button_to("X", "/x", variant: :outline, size: :big, inverse: true)

      expect(result).to have_element(:button, class: expected)
    end
  end
end
