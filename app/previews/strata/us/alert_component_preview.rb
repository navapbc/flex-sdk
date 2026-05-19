# frozen_string_literal: true

module Strata
  module US
    # AlertComponentPreview provides a playground preview for the Strata::US::AlertComponent.
    #
    # Use the Lookbook params tab (or URL query parameters) to switch between
    # alert types, edit the heading and body, and toggle the slim and with-icon
    # variants.
    class AlertComponentPreview < Lookbook::Preview
      layout "strata/component_preview"

      ALERT_TYPES = %w[info warning success error emergency].freeze
      HEADING_TAGS = %w[h1 h2 h3 h4 h5 h6].freeze

      # @label Playground
      # @param type select { choices: [info, warning, success, error, emergency] }
      # @param heading text
      # @param body textarea
      # @param slim toggle
      # @param with_icon toggle
      # @param heading_tag select { choices: [h1, h2, h3, h4, h5, h6] }
      def alert(
        type: "info",
        heading: "Informative status",
        body: "See the 'params' tab to customize this alert's type, content, and appearance.",
        slim: false,
        with_icon: true,
        heading_tag: "h4"
      )
        component = Strata::US::AlertComponent.new(
          type: ALERT_TYPES.include?(type.to_s) ? type.to_sym : :info,
          slim: slim,
          with_icon: with_icon,
          heading_tag: HEADING_TAGS.include?(heading_tag.to_s) ? heading_tag.to_sym : :h4,
          role: %w[error emergency].include?(type.to_s) ? "alert" : nil
        )

        render component do |alert|
          alert.with_heading { heading } if heading.present?
          alert.with_body { body } if body.present?
        end
      end
    end
  end
end
