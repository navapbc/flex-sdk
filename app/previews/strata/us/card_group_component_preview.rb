# frozen_string_literal: true

module Strata
  module US
    # CardGroupComponentPreview provides preview examples for the Strata::US::CardGroupComponent.
    #
    # Previews with a footer button render via sibling .html.erb templates because
    # nested `render` calls don't work inside slot blocks in a Lookbook preview method
    # — see app/previews/strata/us/card_group_component_preview/.
    class CardGroupComponentPreview < Lookbook::Preview
      layout "strata/component_preview"

      # Public so the sibling templates can reference it as
      # Strata::US::CardGroupComponentPreview::PREVIEW_IMAGE_URL.
      PREVIEW_IMAGE_URL = Strata::US::CardComponentPreview::PREVIEW_IMAGE_URL

      # @label Default group
      # Renders via the sibling `default.html.erb` template.
      def default; end

      # @label Responsive grid (2-up tablet, 3-up widescreen)
      # Renders via the sibling `responsive_grid.html.erb` template.
      def responsive_grid; end

      # @label Group of flag cards
      def flag_cards
        render Strata::US::CardGroupComponent.new do |group|
          group.with_card(flag: true) do |card|
            card.with_header { "First flag card" }
            card.with_media { preview_image }
            card.with_body { "<p>Flag card with media beside the content.</p>".html_safe }
          end
          group.with_card(flag: true) do |card|
            card.with_header { "Second flag card" }
            card.with_media { preview_image }
            card.with_body { "<p>Flag card with media beside the content.</p>".html_safe }
          end
        end
      end

      private

      def preview_image
        image_tag(PREVIEW_IMAGE_URL, alt: "Card preview placeholder")
      end
    end
  end
end
