# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::US::IconComponent, type: :component do
  def render_icon(**kwargs)
    render_inline(described_class.new(**kwargs))
  end

  describe "default render" do
    it "renders <svg class='usa-icon'> with focusable='false' and role='img'" do
      render_icon(name: :check)

      expect(page).to have_css('svg.usa-icon[focusable="false"][role="img"]')
    end

    it "renders <use> referencing the USWDS sprite asset" do
      render_icon(name: :check)

      use_node = page.find("svg.usa-icon use", visible: :all)
      # Asset pipeline may fingerprint the filename as sprite-<digest>.svg.
      expect(use_node[:href]).to match(%r{@uswds/uswds/dist/img/sprite[^/]*\.svg#check\z})
    end

    it "is decorative by default — sets aria-hidden and renders no <title>" do
      render_icon(name: :check)

      expect(page).to have_css('svg.usa-icon[aria-hidden="true"]')
      expect(page).not_to have_css("svg.usa-icon title", visible: :all)
    end

    it "applies no size modifier by default" do
      render_icon(name: :check)

      svg_classes = page.find("svg.usa-icon")[:class].split
      expect(svg_classes.grep(/usa-icon--size-/)).to be_empty
    end
  end

  describe "name" do
    it "accepts a Symbol" do
      render_icon(name: :arrow_back)

      use_node = page.find("svg.usa-icon use", visible: :all)
      expect(use_node[:href]).to end_with("#arrow_back")
    end

    it "accepts a String" do
      render_icon(name: "arrow_back")

      use_node = page.find("svg.usa-icon use", visible: :all)
      expect(use_node[:href]).to end_with("#arrow_back")
    end

    it "raises ArgumentError when name is nil" do
      expect { render_icon(name: nil) }.to raise_error(ArgumentError, /name/)
    end

    it "raises ArgumentError when name is blank" do
      expect { render_icon(name: "") }.to raise_error(ArgumentError, /name/)
    end

    it "raises ArgumentError when name is whitespace-only" do
      expect { render_icon(name: "   ") }.to raise_error(ArgumentError, /name/)
    end
  end

  describe "size" do
    (3..9).each do |size|
      it "adds usa-icon--size-#{size} when size: #{size}" do
        render_icon(name: :check, size: size)
        expect(page).to have_css(".usa-icon.usa-icon--size-#{size}")
      end
    end

    it "raises ArgumentError when size is outside the allowed range" do
      expect { render_icon(name: :check, size: 2) }.to raise_error(ArgumentError, /size/)
      expect { render_icon(name: :check, size: 10) }.to raise_error(ArgumentError, /size/)
    end

    it "raises ArgumentError when size is not an Integer" do
      expect { render_icon(name: :check, size: "4") }.to raise_error(ArgumentError, /size/)
    end
  end

  describe "decorative & title" do
    it "with decorative: false and title:, omits aria-hidden and renders a <title>" do
      render_icon(name: :warning, decorative: false, title: "Warning")

      expect(page).not_to have_css("svg.usa-icon[aria-hidden]")
      expect(page).to have_css("svg.usa-icon title", text: "Warning", visible: :all)
    end

    it "with decorative: false, gives the <svg> an aria-labelledby pointing at the <title>" do
      render_icon(name: :warning, decorative: false, title: "Warning")

      svg = page.find("svg.usa-icon")
      title_id = page.find("svg.usa-icon title", visible: :all)[:id]
      expect(title_id).to be_present
      expect(svg["aria-labelledby"]).to eq(title_id)
    end

    it "raises ArgumentError when decorative: false but no title is given" do
      expect {
        render_icon(name: :warning, decorative: false)
      }.to raise_error(ArgumentError, /title/)
    end

    it "raises ArgumentError when decorative: false and title is blank" do
      expect {
        render_icon(name: :warning, decorative: false, title: "")
      }.to raise_error(ArgumentError, /title/)
    end

    it "raises ArgumentError when decorative: false and title is whitespace-only" do
      expect {
        render_icon(name: :warning, decorative: false, title: "   ")
      }.to raise_error(ArgumentError, /title/)
    end

    it "ignores title when decorative: true (the default)" do
      render_icon(name: :check, title: "Ignored")

      expect(page).to have_css('svg.usa-icon[aria-hidden="true"]')
      expect(page).not_to have_css("svg.usa-icon title", visible: :all)
    end

    it "strips a caller-supplied aria-hidden when decorative: false" do
      render_icon(
        name: :warning,
        decorative: false,
        title: "Warning",
        "aria-hidden": "true"
      )

      expect(page).not_to have_css("svg.usa-icon[aria-hidden]")
    end

    it "ignores a caller-supplied aria-hidden when decorative: true" do
      render_icon(name: :check, "aria-hidden": "false")

      expect(page).to have_css('svg.usa-icon[aria-hidden="true"]')
    end
  end

  describe "classes & html attributes" do
    it "appends classes to the <svg>" do
      render_icon(name: :check, classes: "text-success margin-right-05")

      expect(page).to have_css("svg.usa-icon.text-success.margin-right-05")
    end

    it "combines size modifier and extra classes" do
      render_icon(name: :check, size: 5, classes: "text-primary")

      expect(page).to have_css("svg.usa-icon.usa-icon--size-5.text-primary")
    end

    it "forwards id, data-*, and aria-* attributes to the <svg>" do
      render_icon(
        name: :check,
        id: "my-icon",
        data: { test: "yes" },
        "aria-label": "checked"
      )

      expect(page).to have_css('svg.usa-icon#my-icon[data-test="yes"][aria-label="checked"]')
    end

    it "defaults focusable to 'false' but allows the caller to override" do
      render_icon(name: :check)
      expect(page).to have_css('svg.usa-icon[focusable="false"]')

      render_icon(name: :check, focusable: "true")
      expect(page).to have_css('svg.usa-icon[focusable="true"]')
    end

    it "defaults role to 'img' but allows the caller to override" do
      render_icon(name: :check)
      expect(page).to have_css('svg.usa-icon[role="img"]')

      render_icon(name: :check, role: "presentation")
      expect(page).to have_css('svg.usa-icon[role="presentation"]')
    end
  end
end
