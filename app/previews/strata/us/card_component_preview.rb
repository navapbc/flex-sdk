# frozen_string_literal: true

module Strata
  module US
    # CardComponentPreview provides preview examples for the Strata::US::CardComponent.
    #
    # Previews with a footer button render via sibling .html.erb templates because
    # nested `render` calls don't work inside slot blocks in a Lookbook preview method
    # — see app/previews/strata/us/card_component_preview/.
    class CardComponentPreview < Lookbook::Preview
      layout "strata/component_preview"

      # Public so the sibling templates can reference it as
      # Strata::US::CardComponentPreview::PREVIEW_IMAGE_URL.
      PREVIEW_IMAGE_URL = "data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA0MDAgMjQwIiByb2xlPSJpbWciIGFyaWEtbGFiZWw9IkNhcmQgcHJldmlldyBwbGFjZWhvbGRlciI+CiAgPHJlY3Qgd2lkdGg9IjQwMCIgaGVpZ2h0PSIyNDAiIGZpbGw9IiMwMDVlYTIiLz4KICA8cmVjdCB4PSIwIiB5PSIxODAiIHdpZHRoPSI0MDAiIGhlaWdodD0iNjAiIGZpbGw9IiMxNjJlNTEiLz4KICA8Y2lyY2xlIGN4PSIzMjAiIGN5PSI4MCIgcj0iMzIiIGZpbGw9IiNmZmJlMmUiLz4KICA8dGV4dCB4PSIyMDAiIHk9IjEzMCIgZm9udC1mYW1pbHk9IkhlbHZldGljYSwgQXJpYWwsIHNhbnMtc2VyaWYiIGZvbnQtc2l6ZT0iMjIiIGZvbnQtd2VpZ2h0PSI2MDAiIGZpbGw9IiNmZmZmZmYiIHRleHQtYW5jaG9yPSJtaWRkbGUiPkNhcmQgcHJldmlldyBwbGFjZWhvbGRlcjwvdGV4dD4KPC9zdmc+Cg=="

      # @label Default
      # Renders via the sibling `default.html.erb` template.
      def default; end

      # @label With media
      # Renders via the sibling `with_media.html.erb` template.
      def with_media; end

      # @label Flag layout
      # Renders via the sibling `flag.html.erb` template.
      def flag; end

      # @label Flag with media on right
      # Renders via the sibling `flag_media_right.html.erb` template.
      def flag_media_right; end

      # @label Header first
      # Renders via the sibling `header_first.html.erb` template.
      def header_first; end

      # @label Media inset
      def media_inset
        render Strata::US::CardComponent.new(media_inset: true) do |card|
          card.with_header { "Inset media" }
          card.with_media { preview_image }
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

      private

      def preview_image
        image_tag(PREVIEW_IMAGE_URL, alt: "Card preview placeholder")
      end
    end
  end
end
