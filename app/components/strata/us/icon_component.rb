# frozen_string_literal: true

module Strata
  module US
    # IconComponent renders a USWDS icon from the bundled sprite sheet
    # (`@uswds/uswds/dist/img/sprite.svg`).
    #
    # See https://designsystem.digital.gov/components/icon/ for the catalog of
    # available icon names and styling guidance.
    #
    # By default icons render as decorative (`aria-hidden="true"`). Pass
    # `decorative: false` together with `title:` to render a meaningful icon
    # exposed to assistive technology.
    #
    # @example Decorative icon
    #   <%= render Strata::US::IconComponent.new(name: :check) %>
    #
    # @example Sized + extra classes
    #   <%= render Strata::US::IconComponent.new(
    #         name: :arrow_back, size: 4, classes: "text-primary"
    #       ) %>
    #
    # @example Meaningful icon (announced by screen readers)
    #   <%= render Strata::US::IconComponent.new(
    #         name: :warning, decorative: false, title: "Warning",
    #         classes: "text-warning"
    #       ) %>
    class IconComponent < ViewComponent::Base
      ALLOWED_SIZES = (3..9).freeze

      def initialize(name:, size: nil, decorative: true, title: nil, classes: nil, **html_attributes)
        raise ArgumentError, "name is required" if name.nil? || name.to_s.empty?
        validate_size!(size) unless size.nil?

        @decorative = decorative
        @title = title

        if !@decorative && (@title.nil? || @title.to_s.empty?)
          raise ArgumentError, "title is required when decorative: false"
        end

        @name = name.to_s
        @size = size
        @classes = classes
        @html_attributes = html_attributes
      end

      def svg_attributes
        attrs = @html_attributes.dup
        attrs[:class] = svg_classes
        attrs[:focusable] = "false"
        attrs[:role] = "img"

        if @decorative
          attrs[:"aria-hidden"] = "true"
        else
          attrs[:"aria-labelledby"] = title_id
        end

        attrs
      end

      def show_title?
        !@decorative
      end

      def title_text
        @title
      end

      def title_id
        @title_id ||= "icon-title-#{SecureRandom.hex(4)}"
      end

      def sprite_href
        "#{helpers.asset_path('@uswds/uswds/dist/img/sprite.svg')}##{@name}"
      end

      private

      def svg_classes
        class_names(
          "usa-icon",
          { "usa-icon--size-#{@size}" => @size },
          @classes
        )
      end

      def validate_size!(size)
        return if size.is_a?(Integer) && ALLOWED_SIZES.cover?(size)

        raise ArgumentError,
          "Invalid size: #{size.inspect}. Must be an Integer in #{ALLOWED_SIZES.inspect}"
      end
    end
  end
end
