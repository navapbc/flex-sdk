# frozen_string_literal: true

module Strata
  module US
    # ModalComponentPreview shows the Strata::US::ModalComponent in its common
    # configurations. Each preview renders a button-styled opener via
    # +strata_link_to ..., modal: id, as: :button+ next to the modal markup so
    # the preview is interactive — USWDS JS is loaded in the preview layout.
    class ModalComponentPreview < Lookbook::Preview
      layout "strata/component_preview"

      HEADING_TAGS = %w[h1 h2 h3 h4 h5 h6].freeze

      # @label Playground
      # @param id text
      # @param heading text
      # @param body textarea
      # @param footer_button_label text
      # @param large toggle
      # @param forced_action toggle
      # @param heading_tag select { choices: [h1, h2, h3, h4, h5, h6] }
      def playground(
        id: "playground-modal",
        heading: "Are you sure?",
        body: "Your changes will be lost if you leave this page without saving. Are you sure you want to continue?",
        footer_button_label: "Continue without saving",
        large: false,
        forced_action: false,
        heading_tag: "h2"
      )
        render_with_template(
          locals: {
            id: id,
            heading: heading,
            body: body,
            footer_button_label: footer_button_label,
            large: large,
            forced_action: forced_action,
            heading_tag: HEADING_TAGS.include?(heading_tag.to_s) ? heading_tag.to_sym : :h2
          }
        )
      end

      # @label Basic
      def basic; end

      # @label Large
      def large; end

      # @label Forced action (no close button)
      def forced_action; end
    end
  end
end
