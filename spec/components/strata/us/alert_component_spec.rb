# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::US::AlertComponent, type: :component do
  def render_alert(**kwargs, &block)
    render_inline(described_class.new(**kwargs), &block)
  end

  describe "default render" do
    it "renders an info alert with icon, not slim" do
      render_alert(type: :info) { |a| a.with_body { "Hello" } }

      expect(page).to have_css("div.usa-alert.usa-alert--info")
      expect(page).not_to have_css(".usa-alert--slim")
      expect(page).not_to have_css(".usa-alert--no-icon")
    end

    it "wraps body slot content in p.usa-alert__text inside .usa-alert__body" do
      render_alert(type: :info) { |a| a.with_body { "Hello world" } }

      expect(page).to have_css(".usa-alert__body p.usa-alert__text", text: "Hello world")
    end

    it "renders no heading element when heading slot is omitted" do
      render_alert(type: :info) { |a| a.with_body { "Hello world" } }

      expect(page).not_to have_css(".usa-alert__heading")
    end
  end

  describe "type modifier" do
    %i[info warning success error emergency].each do |type|
      it "renders usa-alert--#{type} for type: #{type.inspect}" do
        render_alert(type: type) { |a| a.with_body { "body" } }
        expect(page).to have_css(".usa-alert.usa-alert--#{type}")
      end
    end

    it "raises ArgumentError when type is not one of the allowed symbols" do
      expect {
        render_alert(type: :nonsense) { |a| a.with_body { "body" } }
      }.to raise_error(ArgumentError, /type/)
    end

    it "raises ArgumentError when type is nil" do
      expect {
        render_alert(type: nil) { |a| a.with_body { "body" } }
      }.to raise_error(ArgumentError, /type/)
    end
  end

  describe "slim" do
    it "adds usa-alert--slim when slim: true" do
      render_alert(type: :info, slim: true) { |a| a.with_body { "body" } }
      expect(page).to have_css(".usa-alert.usa-alert--slim")
    end
  end

  describe "with_icon" do
    it "omits usa-alert--no-icon when with_icon: true (default)" do
      render_alert(type: :info) { |a| a.with_body { "body" } }
      expect(page).not_to have_css(".usa-alert--no-icon")
    end

    it "adds usa-alert--no-icon when with_icon: false" do
      render_alert(type: :info, with_icon: false) { |a| a.with_body { "body" } }
      expect(page).to have_css(".usa-alert.usa-alert--no-icon")
    end
  end

  describe "heading slot" do
    it "renders h4.usa-alert__heading by default" do
      render_alert(type: :info) do |a|
        a.with_heading { "Important" }
        a.with_body { "body" }
      end
      expect(page).to have_css(".usa-alert__body h4.usa-alert__heading", text: "Important")
    end

    it "uses heading_tag override" do
      render_alert(type: :info, heading_tag: :h2) do |a|
        a.with_heading { "Important" }
        a.with_body { "body" }
      end
      expect(page).to have_css("h2.usa-alert__heading", text: "Important")
    end

    it "allows HTML inside the heading slot" do
      render_alert(type: :info) do |a|
        a.with_heading { "<em>Saved</em>".html_safe }
        a.with_body { "body" }
      end
      expect(page).to have_css(".usa-alert__heading em", text: "Saved")
    end
  end

  describe "body slot" do
    it "allows HTML inside the body slot, still wrapped in p.usa-alert__text" do
      render_alert(type: :info) do |a|
        a.with_body { "<strong>bold</strong>".html_safe }
      end
      expect(page).to have_css("p.usa-alert__text strong", text: "bold")
    end
  end

  describe "role" do
    it "does not set role by default" do
      render_alert(type: :info) { |a| a.with_body { "body" } }
      expect(page).not_to have_css(".usa-alert[role]")
    end

    it "forwards role when specified" do
      render_alert(type: :error, role: "alert") { |a| a.with_body { "body" } }
      expect(page).to have_css('.usa-alert[role="alert"]')
    end
  end

  describe "extra classes & html attributes" do
    it "appends classes to the wrapper" do
      render_alert(type: :info, classes: "margin-top-2 extra") { |a| a.with_body { "body" } }
      expect(page).to have_css(".usa-alert.usa-alert--info.margin-top-2.extra")
    end

    it "forwards id, data-*, and aria-* attributes to the wrapper" do
      render_alert(
        type: :info,
        id: "my-alert",
        data: { test: "yes" },
        "aria-label": "alerty"
      ) { |a| a.with_body { "body" } }

      expect(page).to have_css('.usa-alert#my-alert[data-test="yes"][aria-label="alerty"]')
    end
  end
end
