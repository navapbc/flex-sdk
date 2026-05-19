# frozen_string_literal: true

module Strata
  module US
    # CardGroupComponentPreview provides preview examples for the Strata::US::CardGroupComponent.
    class CardGroupComponentPreview < Lookbook::Preview
      layout "strata/component_preview"

      # @label Default group
      def default
        render Strata::US::CardGroupComponent.new do |group|
          group.with_card do |card|
            card.with_header { "First card" }
            card.with_body { "<p>Content for the first card.</p>".html_safe }
            card.with_footer { '<button class="usa-button">Action</button>'.html_safe }
          end
          group.with_card do |card|
            card.with_header { "Second card" }
            card.with_body { "<p>Content for the second card.</p>".html_safe }
            card.with_footer { '<button class="usa-button">Action</button>'.html_safe }
          end
          group.with_card do |card|
            card.with_header { "Third card" }
            card.with_body { "<p>Content for the third card.</p>".html_safe }
            card.with_footer { '<button class="usa-button">Action</button>'.html_safe }
          end
        end
      end

      # @label Responsive grid (2-up tablet, 3-up widescreen)
      def responsive_grid
        render Strata::US::CardGroupComponent.new do |group|
          6.times do |i|
            group.with_card(classes: "tablet:grid-col-6 widescreen:grid-col-4") do |card|
              card.with_header { "Card #{i + 1}" }
              card.with_media { preview_image }
              card.with_body { "<p>Each card spans 6 columns at tablet width and 4 columns at widescreen.</p>".html_safe }
              card.with_footer { '<button class="usa-button">Action</button>'.html_safe }
            end
          end
        end
      end

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
        image_tag("data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA0MDAgMjQwIiByb2xlPSJpbWciIGFyaWEtbGFiZWw9IkNhcmQgcHJldmlldyBwbGFjZWhvbGRlciI+CiAgPHJlY3Qgd2lkdGg9IjQwMCIgaGVpZ2h0PSIyNDAiIGZpbGw9IiMwMDVlYTIiLz4KICA8cmVjdCB4PSIwIiB5PSIxODAiIHdpZHRoPSI0MDAiIGhlaWdodD0iNjAiIGZpbGw9IiMxNjJlNTEiLz4KICA8Y2lyY2xlIGN4PSIzMjAiIGN5PSI4MCIgcj0iMzIiIGZpbGw9IiNmZmJlMmUiLz4KICA8dGV4dCB4PSIyMDAiIHk9IjEzMCIgZm9udC1mYW1pbHk9IkhlbHZldGljYSwgQXJpYWwsIHNhbnMtc2VyaWYiIGZvbnQtc2l6ZT0iMjIiIGZvbnQtd2VpZ2h0PSI2MDAiIGZpbGw9IiNmZmZmZmYiIHRleHQtYW5jaG9yPSJtaWRkbGUiPkNhcmQgcHJldmlldyBwbGFjZWhvbGRlcjwvdGV4dD4KPC9zdmc+Cg==", alt: "Card preview placeholder")
      end
    end
  end
end
