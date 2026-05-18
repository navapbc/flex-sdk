# frozen_string_literal: true

module Strata
  module US
    # CardComponentPreview provides preview examples for the Strata::US::CardComponent.
    class CardComponentPreview < Lookbook::Preview
      layout "strata/component_preview"

      # @label Default
      def default
        render Strata::US::CardComponent.new do |card|
          card.with_header { "Default card" }
          card.with_body { "<p>A card with a header, body, and footer.</p>".html_safe }
          card.with_footer { '<button class="usa-button">Action</button>'.html_safe }
        end
      end

      # @label With media
      def with_media
        render Strata::US::CardComponent.new do |card|
          card.with_header { "Card with media" }
          card.with_media do
            '<img src="https://designsystem.digital.gov/img/introducing-uswds-2-0/built-to-grow--alt.jpg" alt="USWDS sample image" />'.html_safe
          end
          card.with_body { "<p>This card includes a media image above the body.</p>".html_safe }
          card.with_footer { '<button class="usa-button">Read more</button>'.html_safe }
        end
      end

      # @label Flag layout
      def flag
        render Strata::US::CardComponent.new(flag: true) do |card|
          card.with_header { "Flag layout" }
          card.with_media do
            '<img src="https://designsystem.digital.gov/img/introducing-uswds-2-0/built-to-grow--alt.jpg" alt="USWDS sample image" />'.html_safe
          end
          card.with_body { "<p>The flag variant places media beside the content.</p>".html_safe }
          card.with_footer { '<button class="usa-button">Action</button>'.html_safe }
        end
      end

      # @label Flag with media on right
      def flag_media_right
        render Strata::US::CardComponent.new(flag_media_right: true) do |card|
          card.with_header { "Media on the right" }
          card.with_media do
            '<img src="https://designsystem.digital.gov/img/introducing-uswds-2-0/built-to-grow--alt.jpg" alt="USWDS sample image" />'.html_safe
          end
          card.with_body { "<p>This flag variant positions media on the right.</p>".html_safe }
          card.with_footer { '<button class="usa-button">Action</button>'.html_safe }
        end
      end

      # @label Header first
      def header_first
        render Strata::US::CardComponent.new(header_first: true) do |card|
          card.with_header { "Header first" }
          card.with_media do
            '<img src="https://designsystem.digital.gov/img/introducing-uswds-2-0/built-to-grow--alt.jpg" alt="USWDS sample image" />'.html_safe
          end
          card.with_body { "<p>The header appears before the media.</p>".html_safe }
          card.with_footer { '<button class="usa-button">Action</button>'.html_safe }
        end
      end

      # @label Media inset
      def media_inset
        render Strata::US::CardComponent.new(media_inset: true) do |card|
          card.with_header { "Inset media" }
          card.with_media do
            '<img src="https://designsystem.digital.gov/img/introducing-uswds-2-0/built-to-grow--alt.jpg" alt="USWDS sample image" />'.html_safe
          end
          card.with_body { "<p>Media is inset from the card edges.</p>".html_safe }
        end
      end

      # @label Header only
      def header_only
        render Strata::US::CardComponent.new do |card|
          card.with_header { "Header only" }
        end
      end

      # @label Body only
      def body_only
        render Strata::US::CardComponent.new do |card|
          card.with_body { "<p>This card has a body but no header or footer.</p>".html_safe }
        end
      end
    end
  end
end
