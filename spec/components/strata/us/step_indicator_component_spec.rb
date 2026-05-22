# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::US::StepIndicatorComponent, type: :component do
  let(:steps) { [ :personal_info, :review, :submit ] }
  let(:current_step) { :review }

  def render_default(**overrides)
    args = { steps: steps, current_step: current_step }.merge(overrides)
    render_inline(described_class.new(**args))
  end

  describe "structural markup" do
    it "renders a div.usa-step-indicator wrapping the segments list and header" do
      render_default

      expect(page).to have_css("div.usa-step-indicator[aria-label='progress']")
      expect(page).to have_css("div.usa-step-indicator > ol.usa-step-indicator__segments")
      expect(page).to have_css(
        "div.usa-step-indicator > div.usa-step-indicator__header > h4.usa-step-indicator__heading"
      )
    end

    it "renders one <li> per step" do
      render_default

      expect(page).to have_css("li.usa-step-indicator__segment", count: steps.length)
    end

    it "renders the heading counter as 'Step N of M' with current step number" do
      render_default

      expect(page).to have_css(".usa-step-indicator__heading-counter .usa-sr-only", text: "Step")
      expect(page).to have_css(".usa-step-indicator__current-step", text: "2")
      expect(page).to have_css(".usa-step-indicator__total-steps", text: "of 3")
    end
  end

  describe "segment state — complete (steps before the current step)" do
    it "marks them with usa-step-indicator__segment--complete" do
      render_default

      segments = page.all("li.usa-step-indicator__segment")
      expect(segments[0][:class]).to include("usa-step-indicator__segment--complete")
    end

    it "renders 'completed' as screen-reader text" do
      render_default

      first = page.all("li.usa-step-indicator__segment").first
      expect(first).to have_css(".usa-sr-only", text: "completed")
    end
  end

  describe "segment state — current (the active step)" do
    it "marks it with both --current and --complete (per existing logic)" do
      render_default

      current = page.find("li.usa-step-indicator__segment--current")
      expect(current[:class]).to include("usa-step-indicator__segment--complete")
    end

    it "marks exactly one segment as --current" do
      render_default

      expect(page).to have_css("li.usa-step-indicator__segment--current", count: 1)
    end

    it "shows the current step's display name in the heading text" do
      render_default

      expect(page).to have_css(
        ".usa-step-indicator__heading-text",
        text: "Review"
      )
    end
  end

  describe "segment state — future (steps after the current step)" do
    it "does not mark them with --complete or --current" do
      render_default

      last = page.all("li.usa-step-indicator__segment").last
      expect(last[:class]).not_to include("usa-step-indicator__segment--complete")
      expect(last[:class]).not_to include("usa-step-indicator__segment--current")
    end

    it "renders 'not completed' as screen-reader text" do
      render_default

      last = page.all("li.usa-step-indicator__segment").last
      expect(last).to have_css(".usa-sr-only", text: "not completed")
    end
  end

  describe "type: :counters variant" do
    it "adds usa-step-indicator--counters to the root when type: :counters" do
      render_default(type: :counters)

      expect(page).to have_css("div.usa-step-indicator.usa-step-indicator--counters")
    end

    it "does not add usa-step-indicator--counters by default" do
      render_default

      expect(page).not_to have_css(".usa-step-indicator--counters")
    end

    it "ignores unknown type values" do
      render_default(type: :something_else)

      expect(page).not_to have_css(".usa-step-indicator--counters")
    end
  end

  describe "i18n display names" do
    let(:scope) { "spec.step_indicator_component.steps" }

    around do |example|
      I18n.backend.store_translations(
        :en,
        spec: { step_indicator_component: { steps: { review: "Review your answers" } } }
      )
      example.run
    end

    it "uses the translation under translation_scope for each step's label" do
      render_default(translation_scope: scope)

      expect(page).to have_css(".usa-step-indicator__segment-label", text: "Review your answers")
    end

    it "uses the translation in the heading text" do
      render_default(translation_scope: scope)

      expect(page).to have_css(".usa-step-indicator__heading-text", text: "Review your answers")
    end

    it "falls back to a humanized symbol when no translation exists for a step" do
      render_default(translation_scope: scope)

      expect(page).to have_css(".usa-step-indicator__segment-label", text: "Personal info")
      expect(page).to have_css(".usa-step-indicator__segment-label", text: "Submit")
    end

    it "defaults translation_scope to strata.application_forms.steps" do
      I18n.backend.store_translations(
        :en,
        strata: { application_forms: { steps: { review: "Default-scope review" } } }
      )

      render_default

      expect(page).to have_css(".usa-step-indicator__heading-text", text: "Default-scope review")
      expect(page).to have_css(".usa-step-indicator__segment-label", text: "Default-scope review")
    end

    it "coerces an explicit translation_scope: nil to the default scope" do
      I18n.backend.store_translations(
        :en,
        strata: { application_forms: { steps: { review: "Default-scope review" } } }
      )

      render_default(translation_scope: nil)

      expect(page).to have_css(".usa-step-indicator__heading-text", text: "Default-scope review")
      expect(page).to have_css(".usa-step-indicator__segment-label", text: "Default-scope review")
    end
  end

  describe "large_header option" do
    it "adds font-heading-xl to the heading text when true" do
      render_default(large_header: true)

      expect(page).to have_css(".usa-step-indicator__heading-text.font-heading-xl")
    end

    it "does not add font-heading-xl by default" do
      render_default

      expect(page).not_to have_css(".font-heading-xl")
    end
  end

  describe "header_first option" do
    it "renders the header before the segments and adds margin-bottom-2 when true" do
      render_default(header_first: true)

      expect(page).to have_css(
        "div.usa-step-indicator > div.usa-step-indicator__header.margin-bottom-2 + ol.usa-step-indicator__segments"
      )
    end

    it "renders the header after the segments by default, without margin-bottom-2" do
      render_default

      expect(page).to have_css(
        "div.usa-step-indicator > ol.usa-step-indicator__segments + div.usa-step-indicator__header"
      )
      expect(page).not_to have_css(".usa-step-indicator__header.margin-bottom-2")
    end
  end

  describe "string inputs (steps and current_step)" do
    it "accepts string values and normalizes them to symbols" do
      render_inline(described_class.new(
        steps: [ "personal_info", "review", "submit" ],
        current_step: "review"
      ))

      expect(page).to have_css("li.usa-step-indicator__segment", count: 3)
      expect(page).to have_css("li.usa-step-indicator__segment--current")
      expect(page).to have_css(".usa-step-indicator__current-step", text: "2")
    end
  end

  describe "current_step not in steps" do
    it "raises ArgumentError when current_step is not in steps" do
      expect {
        described_class.new(steps: [ :a, :b, :c ], current_step: :unknown)
      }.to raise_error(
        ArgumentError,
        "Invalid current_step: :unknown. Must be one of [:a, :b, :c]"
      )
    end

    it "raises ArgumentError when steps is empty" do
      expect {
        described_class.new(steps: [], current_step: :anything)
      }.to raise_error(
        ArgumentError,
        "Invalid current_step: :anything. Must be one of []"
      )
    end

    it "raises at initialization (before render)" do
      expect {
        described_class.new(steps: [ :a, :b ], current_step: :c)
      }.to raise_error(ArgumentError)
    end

    it "validates after symbol normalization (string current_step matching symbol steps)" do
      expect {
        described_class.new(steps: [ :a, :b ], current_step: "b")
      }.not_to raise_error
    end

    it "validates after symbol normalization (symbol current_step matching string steps)" do
      expect {
        described_class.new(steps: [ "a", "b" ], current_step: :b)
      }.not_to raise_error
    end
  end

  describe "extra classes & html attributes on the root <div>" do
    it "appends extra classes after the USWDS classes" do
      render_default(classes: "margin-top-2 extra")

      expect(page).to have_css("div.usa-step-indicator.margin-top-2.extra")
    end

    it "keeps usa-step-indicator--counters together with extra classes" do
      render_default(type: :counters, classes: "margin-top-2")

      expect(page).to have_css("div.usa-step-indicator.usa-step-indicator--counters.margin-top-2")
    end

    it "forwards id, data-*, and other html attributes to the root <div>" do
      render_default(id: "my-step", data: { test: "yes" })

      expect(page).to have_css("div.usa-step-indicator#my-step[data-test='yes']")
    end

    it "prefers the dedicated classes: when html_attributes also carries :class" do
      render_default(classes: "from-classes", class: "from-html-attrs")

      expect(page).to have_css("div.usa-step-indicator.from-classes")
      expect(page).not_to have_css("div.from-html-attrs")
    end

    it "does not override the built-in aria-label='progress' from html_attributes" do
      # The component owns aria-label='progress' on the root. We intentionally
      # do not expose it as an option to keep the component focused.
      render_default

      expect(page).to have_css("div.usa-step-indicator[aria-label='progress']")
    end
  end

  describe "XSS safety" do
    it "escapes step display names returned by i18n" do
      I18n.backend.store_translations(
        :en,
        spec: { xss: { steps: { review: "<script>alert(1)</script>" } } }
      )

      render_inline(described_class.new(
        steps: steps,
        current_step: :review,
        translation_scope: "spec.xss.steps"
      ))

      html = page.native.to_html
      expect(html).not_to include("<script>alert(1)</script>")
      expect(html).to include("&lt;script&gt;")
    end
  end
end
