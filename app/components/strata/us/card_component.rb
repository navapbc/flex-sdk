# frozen_string_literal: true

module Strata
  module US
    # CardComponent renders a USWDS card with optional header, media, body, and footer slots.
    #
    # @example Basic usage
    #   <%= render Strata::US::CardComponent.new do |card| %>
    #     <% card.with_header { "Card title" } %>
    #     <% card.with_media do %>
    #       <img src="/path/to/image.jpg" alt="Description" />
    #     <% end %>
    #     <% card.with_body { "<p>Card body content.</p>".html_safe } %>
    #     <% card.with_footer do %>
    #       <%= button_tag "Action", class: "usa-button" %>
    #     <% end %>
    #   <% end %>
    #
    # @example Flag layout with media on the right
    #   <%= render Strata::US::CardComponent.new(flag_media_right: true) do |card| %>
    #     <% card.with_header { "Card title" } %>
    #     <% card.with_body { "Body" } %>
    #   <% end %>
    class CardComponent < ViewComponent::Base
      renders_one :header
      renders_one :media
      renders_one :body
      renders_one :footer

      def initialize(
        tag: :div,
        heading_tag: :h4,
        flag: false,
        flag_media_right: false,
        header_first: false,
        media_inset: false,
        media_exdent: false,
        classes: nil,
        **html_attributes
      )
        @tag = tag
        @heading_tag = heading_tag
        @flag = flag || flag_media_right
        @flag_media_right = flag_media_right
        @header_first = header_first
        @media_inset = media_inset
        @media_exdent = media_exdent
        @classes = classes
        @html_attributes = html_attributes
      end

      def card_classes
        class_names(
          "usa-card",
          {
            "usa-card--flag" => @flag,
            "usa-card--media-right" => @flag_media_right,
            "usa-card--header-first" => @header_first
          },
          @classes
        )
      end

      def media_classes
        class_names(
          "usa-card__media",
          {
            "usa-card__media--inset" => @media_inset,
            "usa-card__media--exdent" => @media_exdent
          }
        )
      end
    end
  end
end
