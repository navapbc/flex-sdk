# frozen_string_literal: true

require "rails_helper"

# The shared/_step_indicator partial is preserved for backward compatibility with
# host apps and generated layouts that already render it. It must continue to
# forward every supported local through to Strata::US::StepIndicatorComponent.
RSpec.describe "strata/shared/_step_indicator.html.erb", type: :view do
  let(:steps) { [ :personal_info, :review, :submit ] }
  let(:current_step) { :review }

  def render_partial(locals)
    render partial: "strata/shared/step_indicator", locals: locals
  end

  describe "forwarding locals to Strata::US::StepIndicatorComponent" do
    it "renders the component's root markup with the given steps and current_step" do
      render_partial(steps: steps, current_step: current_step)

      expect(rendered).to have_css("div.usa-step-indicator")
      expect(rendered).to have_css("li.usa-step-indicator__segment", count: 3)
      expect(rendered).to have_css("li.usa-step-indicator__segment--current")
      expect(rendered).to have_css(".usa-step-indicator__current-step", text: "2")
      expect(rendered).to have_css(".usa-step-indicator__total-steps", text: "of 3")
    end

    it "forwards type: :counters" do
      render_partial(steps: steps, current_step: current_step, type: :counters)

      expect(rendered).to have_css("div.usa-step-indicator.usa-step-indicator--counters")
    end

    it "forwards large_header: true" do
      render_partial(steps: steps, current_step: current_step, large_header: true)

      expect(rendered).to have_css(".usa-step-indicator__heading-text.font-heading-xl")
    end

    it "forwards header_first: true" do
      render_partial(steps: steps, current_step: current_step, header_first: true)

      expect(rendered).to have_css(
        "div.usa-step-indicator > div.usa-step-indicator__header.margin-bottom-2 + ol.usa-step-indicator__segments"
      )
    end

    it "forwards translation_scope" do
      I18n.backend.store_translations(
        :en,
        spec: { partial_step_indicator: { steps: { review: "Forwarded scope label" } } }
      )

      render_partial(
        steps: steps,
        current_step: current_step,
        translation_scope: "spec.partial_step_indicator.steps"
      )

      expect(rendered).to have_css(".usa-step-indicator__heading-text", text: "Forwarded scope label")
      expect(rendered).to have_css(".usa-step-indicator__segment-label", text: "Forwarded scope label")
    end

    it "forwards all locals together (matches the call sites in show templates)" do
      render_partial(
        type: :counters,
        steps: [ :in_progress, :submitted, :decision_made ],
        current_step: :submitted,
        large_header: true,
        header_first: true
      )

      expect(rendered).to have_css("div.usa-step-indicator.usa-step-indicator--counters")
      expect(rendered).to have_css(
        "div.usa-step-indicator__header.margin-bottom-2 + ol.usa-step-indicator__segments"
      )
      expect(rendered).to have_css(".usa-step-indicator__heading-text.font-heading-xl", text: "In review")
      expect(rendered).to have_css(".usa-step-indicator__current-step", text: "2")
    end
  end

  describe "default behavior preserved" do
    it "renders without optional locals (only steps + current_step required)" do
      render_partial(steps: steps, current_step: current_step)

      expect(rendered).not_to have_css(".usa-step-indicator--counters")
      expect(rendered).not_to have_css(".font-heading-xl")
      expect(rendered).not_to have_css(".usa-step-indicator__header.margin-bottom-2")
    end
  end
end
