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

      # @label Group of flag cards
      def flag_cards
        render Strata::US::CardGroupComponent.new do |group|
          group.with_card(flag: true) do |card|
            card.with_header { "First flag card" }
            card.with_media do
              '<img src="https://designsystem.digital.gov/img/introducing-uswds-2-0/built-to-grow--alt.jpg" alt="USWDS sample image" />'.html_safe
            end
            card.with_body { "<p>Flag card with media beside the content.</p>".html_safe }
          end
          group.with_card(flag: true) do |card|
            card.with_header { "Second flag card" }
            card.with_media do
              '<img src="https://designsystem.digital.gov/img/introducing-uswds-2-0/built-to-grow--alt.jpg" alt="USWDS sample image" />'.html_safe
            end
            card.with_body { "<p>Flag card with media beside the content.</p>".html_safe }
          end
        end
      end
    end
  end
end
