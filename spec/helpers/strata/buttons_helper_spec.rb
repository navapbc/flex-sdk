# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::ButtonsHelper, type: :helper do
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
