# frozen_string_literal: true

module Strata
  module US
    # IconComponentPreview provides previews for the Strata::US::IconComponent.
    #
    # Use the Lookbook params tab (or URL query parameters) on the playground
    # to switch icons, sizes, colors, and the decorative/title behavior.
    class IconComponentPreview < Lookbook::Preview
      layout "strata/component_preview"

      # A sampling of common USWDS sprite icons for the playground dropdown.
      # The component itself does not validate against this list — any sprite
      # ID will work.
      SAMPLE_ICONS = %w[
        check close warning error info help account_circle arrow_back arrow_forward
        search settings menu mail phone print download upload delete edit
      ].freeze

      # @label Playground
      # @param name select { choices: [check, close, warning, error, info, help, account_circle, arrow_back, arrow_forward, search, settings, menu, mail, phone, print, download, upload, delete, edit] }
      # @param size select { choices: [default, 3, 4, 5, 6, 7, 8, 9] }
      # @param color select { choices: [default, text-primary, text-secondary, text-success, text-warning, text-error] }
      # @param decorative toggle
      # @param title text
      def playground(name: "check", size: "default", color: "default", decorative: true, title: "Icon")
        size_arg = (size.to_s == "default") ? nil : size.to_i
        classes = (color.to_s == "default") ? nil : color.to_s

        render Strata::US::IconComponent.new(
          name: SAMPLE_ICONS.include?(name.to_s) ? name.to_s : "check",
          size: size_arg,
          decorative: decorative,
          title: decorative ? nil : (title.presence || "Icon"),
          classes: classes
        )
      end

      # @label Default (decorative)
      def default
        render Strata::US::IconComponent.new(name: :check)
      end

      # @label Sized
      def sized
        render Strata::US::IconComponent.new(name: :check, size: 5)
      end

      # @label With color
      def with_color
        render Strata::US::IconComponent.new(name: :check, classes: "text-success")
      end

      # @label Meaningful (with title)
      def meaningful
        render Strata::US::IconComponent.new(
          name: :warning,
          decorative: false,
          title: "Warning",
          classes: "text-warning"
        )
      end
    end
  end
end
