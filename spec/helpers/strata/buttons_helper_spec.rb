# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::ButtonsHelper, type: :helper do
  describe "#strata_link_to" do
    it "renders an <a> with the usa-button class" do
      result = helper.strata_link_to("Edit", "/edit")

      expect(result).to have_element(:a, href: "/edit", class: "usa-button", text: "Edit")
    end

    it "applies the variant modifier" do
      result = helper.strata_link_to("Cancel", "/cancel", variant: :outline)

      expect(result).to have_element(:a, href: "/cancel", class: "usa-button usa-button--outline", text: "Cancel")
    end

    it "applies the size modifier" do
      result = helper.strata_link_to("Apply", "/apply", size: :big)

      expect(result).to have_element(:a, class: "usa-button usa-button--big")
    end

    it "applies the inverse modifier" do
      result = helper.strata_link_to("Edit", "/edit", variant: :outline, inverse: true)

      expect(result).to have_element(:a, class: "usa-button usa-button--outline usa-button--inverse")
    end

    it "merges a user-provided :class with the button classes" do
      result = helper.strata_link_to("Edit", "/edit", variant: :outline, class: "margin-top-4")

      expect(result).to have_element(:a, class: "usa-button usa-button--outline margin-top-4")
    end

    it "forwards arbitrary html_options to link_to (id, data-*, aria-*)" do
      result = helper.strata_link_to(
        "Edit",
        "/edit",
        id: "edit-link",
        data: { turbo: "false" },
        "aria-label": "Edit item"
      )

      expect(result).to have_element(:a, id: "edit-link", "data-turbo": "false", "aria-label": "Edit item")
    end

    it "supports the block form (url + block, no body)" do
      result = helper.strata_link_to("/edit", variant: :outline) { "Edit me" }

      expect(result).to have_element(:a, href: "/edit", class: "usa-button usa-button--outline", text: "Edit me")
    end

    it "raises ArgumentError on an unknown variant" do
      expect { helper.strata_link_to("X", "/x", variant: :nonsense) }
        .to raise_error(ArgumentError, /variant/)
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
  end

  describe "delegating to ButtonComponent.css_classes" do
    # Single source of truth: both helpers should produce the same class string
    # as the underlying class helper for matching keyword args.
    it "matches ButtonComponent.css_classes for the same keywords" do
      expected = Strata::US::ButtonComponent.css_classes(variant: :outline, size: :big, inverse: true)

      link = helper.strata_link_to("X", "/x", variant: :outline, size: :big, inverse: true)
      btn  = helper.strata_button_to("X", "/x", variant: :outline, size: :big, inverse: true)

      expect(link).to have_element(:a, class: expected)
      expect(btn).to have_element(:button, class: expected)
    end
  end
end
