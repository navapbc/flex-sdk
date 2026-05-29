# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::US::ModalComponent, type: :component do
  def render_modal(**kwargs, &block)
    render_inline(described_class.new(**kwargs), &block)
  end

  describe "wrapper" do
    it "renders a .usa-modal with the given id" do
      render_modal(id: "confirm") { |m| m.with_content { "body" } }

      expect(page).to have_css("div.usa-modal#confirm")
    end

    it "renders the .usa-modal__content > .usa-modal__main structure" do
      render_modal(id: "confirm") do |m|
        m.with_heading { "Title" }
        m.with_content { "body" }
      end

      expect(page).to have_css(".usa-modal > .usa-modal__content > .usa-modal__main")
    end

    it "raises ArgumentError when id is blank" do
      expect { render_modal(id: "") { |m| m.with_content { "body" } } }
        .to raise_error(ArgumentError, /id/)
      expect { render_modal(id: nil) { |m| m.with_content { "body" } } }
        .to raise_error(ArgumentError, /id/)
    end

    it "appends `classes:` to the wrapper" do
      render_modal(id: "m1", classes: "margin-top-2 extra") { |m| m.with_content { "body" } }

      expect(page).to have_css(".usa-modal.margin-top-2.extra")
    end

    it "forwards arbitrary html_attributes onto the wrapper" do
      render_modal(id: "m1", data: { test: "yes" }, "aria-label": "modal-test") do |m|
        m.with_content { "body" }
      end

      expect(page).to have_css(".usa-modal[data-test='yes'][aria-label='modal-test']")
    end
  end

  describe "large variant" do
    it "adds usa-modal--lg when large: true" do
      render_modal(id: "m1", large: true) { |m| m.with_content { "body" } }

      expect(page).to have_css(".usa-modal.usa-modal--lg")
    end

    it "omits usa-modal--lg by default" do
      render_modal(id: "m1") { |m| m.with_content { "body" } }

      expect(page).not_to have_css(".usa-modal--lg")
    end
  end

  describe "forced_action" do
    it "adds data-force-action to the wrapper when forced_action: true" do
      render_modal(id: "m1", forced_action: true) { |m| m.with_content { "body" } }

      expect(page).to have_css(".usa-modal[data-force-action]")
    end

    it "omits the close button when forced_action: true" do
      render_modal(id: "m1", forced_action: true) { |m| m.with_content { "body" } }

      expect(page).not_to have_css(".usa-modal__close")
    end

    it "renders the close button by default" do
      render_modal(id: "m1") { |m| m.with_content { "body" } }

      expect(page).to have_css("button.usa-button.usa-modal__close[type='button'][data-close-modal]")
    end

    it "does not set data-force-action by default" do
      render_modal(id: "m1") { |m| m.with_content { "body" } }

      expect(page).not_to have_css(".usa-modal[data-force-action]")
    end
  end

  describe "close button" do
    it "renders the USWDS sprite svg with the close glyph" do
      render_modal(id: "m1") { |m| m.with_content { "body" } }

      expect(page).to have_css(".usa-modal__close svg.usa-icon[aria-hidden='true'][focusable='false'][role='img']")
      expect(page).to have_css(".usa-modal__close svg use")
      use_href = page.find(".usa-modal__close svg use")[:href]
      # Asset path may be fingerprinted in test (sprite-<digest>.svg).
      expect(use_href).to match(%r{/assets/@uswds/uswds/dist/img/sprite.*\.svg#close})
    end

    it "uses the i18n-driven aria-label on the close button" do
      render_modal(id: "m1") { |m| m.with_content { "body" } }

      expect(page).to have_css(".usa-modal__close[aria-label='Close this window']")
    end
  end

  describe "heading slot" do
    it "renders the heading inside h2.usa-modal__heading with a derived id" do
      render_modal(id: "confirm") do |m|
        m.with_heading { "Are you sure?" }
        m.with_content { "body" }
      end

      expect(page).to have_css("h2.usa-modal__heading#confirm-heading", text: "Are you sure?")
    end

    it "uses the heading_tag override" do
      render_modal(id: "confirm", heading_tag: :h3) do |m|
        m.with_heading { "Title" }
        m.with_content { "body" }
      end

      expect(page).to have_css("h3.usa-modal__heading#confirm-heading", text: "Title")
    end

    it "wires aria-labelledby on the wrapper to the heading id when heading is present" do
      render_modal(id: "confirm") do |m|
        m.with_heading { "Title" }
        m.with_content { "body" }
      end

      expect(page).to have_css(".usa-modal[aria-labelledby='confirm-heading']")
    end

    it "omits aria-labelledby and the heading element when no heading is provided" do
      render_modal(id: "confirm") { |m| m.with_content { "body" } }

      expect(page).not_to have_css(".usa-modal[aria-labelledby]")
      expect(page).not_to have_css(".usa-modal__heading")
    end

    it "allows HTML inside the heading slot" do
      render_modal(id: "m1") do |m|
        m.with_heading { "<em>Saved</em>".html_safe }
        m.with_content { "body" }
      end

      expect(page).to have_css(".usa-modal__heading em", text: "Saved")
    end
  end

  describe "content slot" do
    it "wraps content in .usa-prose with a derived description id" do
      render_modal(id: "confirm") { |m| m.with_content { "This cannot be undone." } }

      expect(page).to have_css("div.usa-prose#confirm-description", text: "This cannot be undone.")
    end

    it "wires aria-describedby on the wrapper to the description id when content is present" do
      render_modal(id: "confirm") { |m| m.with_content { "body" } }

      expect(page).to have_css(".usa-modal[aria-describedby='confirm-description']")
    end

    it "omits aria-describedby and the content wrapper when no content is provided" do
      render_modal(id: "confirm") { |m| m.with_heading { "Title" } }

      expect(page).not_to have_css(".usa-modal[aria-describedby]")
      expect(page).not_to have_css(".usa-prose")
    end

    it "allows HTML inside the content slot" do
      render_modal(id: "m1") do |m|
        m.with_content { "<p>Congress shall make no law...</p>".html_safe }
      end

      expect(page).to have_css(".usa-prose p", text: "Congress shall make no law...")
    end
  end

  describe "footer slot" do
    it "wraps footer content in .usa-modal__footer" do
      render_modal(id: "m1") do |m|
        m.with_content { "body" }
        m.with_footer { '<button data-close-modal>Yes</button>'.html_safe }
      end

      expect(page).to have_css(".usa-modal__footer button[data-close-modal]", text: "Yes")
    end

    it "omits the .usa-modal__footer wrapper when no footer is provided" do
      render_modal(id: "m1") { |m| m.with_content { "body" } }

      expect(page).not_to have_css(".usa-modal__footer")
    end
  end

  describe "empty slots" do
    it "renders a modal with no heading, content, or footer (close button still present)" do
      render_modal(id: "m1")

      expect(page).to have_css(".usa-modal#m1")
      expect(page).not_to have_css(".usa-modal__heading")
      expect(page).not_to have_css(".usa-prose")
      expect(page).not_to have_css(".usa-modal__footer")
      expect(page).to have_css(".usa-modal__close")
      expect(page).not_to have_css(".usa-modal[aria-labelledby]")
      expect(page).not_to have_css(".usa-modal[aria-describedby]")
    end
  end

  describe ".opener_attrs" do
    it "returns the trigger attribute hash for splatting onto a tag helper" do
      expect(described_class.opener_attrs("my-modal")).to eq(
        href: "#my-modal",
        "aria-controls": "my-modal",
        "data-open-modal": ""
      )
    end

    it "raises ArgumentError on blank id" do
      expect { described_class.opener_attrs("") }.to raise_error(ArgumentError, /id/)
      expect { described_class.opener_attrs(nil) }.to raise_error(ArgumentError, /id/)
    end
  end
end
