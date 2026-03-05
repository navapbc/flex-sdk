# frozen_string_literal: true

module Strata
  # ConditionalFieldComponent wraps content that should be shown or hidden
  # based on a radio button's selected value.
  #
  # @example Basic usage via FormBuilder
  #   <%= f.conditional(:has_employer, eq: "true") do %>
  #     <%= f.text_field :employer_name %>
  #   <% end %>
  #
  # @example Direct component usage
  #   <%= render Strata::ConditionalFieldComponent.new(
  #     source: "form[has_employer]",
  #     match: "true"
  #   ) do %>
  #     <p>Shown when has_employer is true</p>
  #   <% end %>
  #
  class ConditionalFieldComponent < ViewComponent::Base
    def initialize(source:, match:, initially_visible: false, clear: false)
      @source = source
      @match = Array(match).map(&:to_s).join(",")
      @initially_visible = initially_visible
      @clear = clear
    end
  end
end
