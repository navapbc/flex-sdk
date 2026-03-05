# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::ConditionalFieldComponent, type: :component do
  let(:source) { "form[has_employer]" }
  let(:match) { "true" }

  def render_component(clear: false, **options, &block)
    render_inline(described_class.new(
      source: source,
      match: match,
      clear: clear,
      **options
    ), &block)
  end

  context "when clear is false (default)" do
    it "sets the clear data attribute to false" do
      render_component { "Content" }

      expect(page).to have_css('[data-strata--conditional-field-clear-value="false"]', visible: :all)
    end
  end

  context "when clear is true" do
    it "sets the clear data attribute to true" do
      render_component(clear: true) { "Content" }

      expect(page).to have_css('[data-strata--conditional-field-clear-value="true"]', visible: :all)
    end
  end
end
