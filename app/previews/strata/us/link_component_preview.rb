# frozen_string_literal: true

module Strata
  module US
    # LinkComponentPreview provides preview examples for the Strata::US::LinkComponent.
    class LinkComponentPreview < Lookbook::Preview
      layout "strata/component_preview"

      # @label Default
      def default
        render Strata::US::LinkComponent.new(href: "#") do
          "Default link"
        end
      end

      # @label External
      def external
        render Strata::US::LinkComponent.new(href: "https://designsystem.digital.gov/", external: true) do
          "USWDS"
        end
      end

      # @label External (alt) on a dark background
      def external_alt
        content_tag(
          :div,
          render(Strata::US::LinkComponent.new(href: "https://designsystem.digital.gov/", external: true, alt: true) do
            "USWDS"
          end),
          style: "background-color: #1b1b1b; color: white; padding: 1rem;"
        )
      end

      # @label Opens in a new tab (caller-controlled target/rel)
      def new_tab
        render Strata::US::LinkComponent.new(
          href: "https://designsystem.digital.gov/",
          external: true,
          target: "_blank",
          rel: "noopener noreferrer"
        ) do
          "USWDS"
        end
      end
    end
  end
end
