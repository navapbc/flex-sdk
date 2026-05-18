# frozen_string_literal: true

module Strata
  module US
    # AlertComponent renders a USWDS alert in one of five styles (info, warning,
    # success, error, emergency) with optional heading, slim variant, and icon.
    #
    # @example Basic usage
    #   <%= render Strata::US::AlertComponent.new(type: :success) do |alert| %>
    #     <% alert.with_heading { "Saved" } %>
    #     <% alert.with_body { "Your changes have been saved." } %>
    #   <% end %>
    #
    # @example Slim warning without an icon
    #   <%= render Strata::US::AlertComponent.new(type: :warning, slim: true, with_icon: false) do |alert| %>
    #     <% alert.with_body { "Heads up — read-only mode." } %>
    #   <% end %>
    class AlertComponent < ViewComponent::Base
      renders_one :heading
      renders_one :body

      ALLOWED_TYPES = %i[info warning success error emergency].freeze

      def initialize(
        type:,
        slim: false,
        with_icon: true,
        heading_tag: :h4,
        role: nil,
        classes: nil,
        **html_attributes
      )
        raise ArgumentError, "Invalid type: #{type.inspect}. Must be one of #{ALLOWED_TYPES.inspect}" unless ALLOWED_TYPES.include?(type)

        @type = type
        @slim = slim
        @with_icon = with_icon
        @heading_tag = heading_tag
        @classes = classes
        @html_attributes = html_attributes
        @html_attributes[:role] = role if role
      end

      def wrapper_classes
        class_names(
          "usa-alert",
          "usa-alert--#{@type}",
          {
            "usa-alert--slim" => @slim,
            "usa-alert--no-icon" => !@with_icon
          },
          @classes
        )
      end
    end
  end
end
