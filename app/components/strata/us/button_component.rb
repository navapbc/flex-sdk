# frozen_string_literal: true

module Strata
  module US
    # ButtonComponent renders a USWDS button as either a <button> or an <a>.
    # Use the +href:+ keyword to switch from a button element to an anchor styled
    # as a button.
    #
    # See https://designsystem.digital.gov/components/button/.
    #
    # For non-GET actions, the +strata_button_to+ view helper (see
    # Strata::ButtonsHelper) wraps Rails' +button_to+ and applies the same
    # styling. For other Rails-rendered tags — +link_to+, +form.button+,
    # a non-Strata +f.submit+ — pass +Strata::US::ButtonComponent.css_classes+
    # as the +:class+. The class-method helper is the single source of truth.
    #
    # @example A primary button
    #   <%= render Strata::US::ButtonComponent.new do %>
    #     Save
    #   <% end %>
    #
    # @example A secondary, big, link-styled button
    #   <%= render Strata::US::ButtonComponent.new(href: edit_path, variant: :secondary, size: :big) do %>
    #     Edit
    #   <% end %>
    #
    # @example button_to helper, link_to with css_classes
    #   <%= strata_button_to "Delete", path, method: :delete, variant: :secondary %>
    #   <%= link_to "Edit", edit_path,
    #         class: Strata::US::ButtonComponent.css_classes(variant: :outline) %>
    class ButtonComponent < ViewComponent::Base
      ALLOWED_VARIANTS = %i[default secondary accent_cool accent_warm base outline unstyled].freeze
      ALLOWED_SIZES = %i[default big].freeze

      VARIANT_MODIFIERS = {
        default: nil,
        secondary: "usa-button--secondary",
        accent_cool: "usa-button--accent-cool",
        accent_warm: "usa-button--accent-warm",
        base: "usa-button--base",
        outline: "usa-button--outline",
        unstyled: "usa-button--unstyled"
      }.freeze

      def initialize(
        variant: :default,
        size: :default,
        inverse: false,
        type: :button,
        href: nil,
        disabled: false,
        classes: nil,
        **html_attributes
      )
        self.class.send(:validate_variant!, variant)
        self.class.send(:validate_size!, size)

        @variant = variant
        @size = size
        @inverse = inverse
        @type = type
        @href = href
        @disabled = disabled
        @classes = classes
        @html_attributes = html_attributes
      end

      # Returns the USWDS class string for a button-styled element, without
      # rendering the element itself. Use this for +button_to+, +link_to+,
      # +form.button+, and other call sites where Rails owns the tag.
      def self.css_classes(variant: :default, size: :default, inverse: false)
        validate_variant!(variant)
        validate_size!(size)

        parts = [ "usa-button", VARIANT_MODIFIERS[variant] ]
        parts << "usa-button--big" if size == :big
        parts << "usa-button--inverse" if inverse
        parts.compact.join(" ")
      end

      def element_tag
        @href ? :a : :button
      end

      def element_attributes
        attrs = @html_attributes.dup
        attrs[:class] = combined_classes

        if @href
          attrs[:href] = @href
          attrs[:"aria-disabled"] = "true" if @disabled
        else
          attrs[:type] = @type
          attrs[:disabled] = true if @disabled
        end

        attrs
      end

      private

      def combined_classes
        base = self.class.css_classes(variant: @variant, size: @size, inverse: @inverse)
        @classes.present? ? "#{base} #{@classes}" : base
      end

      def self.validate_variant!(variant)
        return if ALLOWED_VARIANTS.include?(variant)

        raise ArgumentError,
          "Invalid variant: #{variant.inspect}. Must be one of #{ALLOWED_VARIANTS.inspect}"
      end
      private_class_method :validate_variant!

      def self.validate_size!(size)
        return if ALLOWED_SIZES.include?(size)

        raise ArgumentError,
          "Invalid size: #{size.inspect}. Must be one of #{ALLOWED_SIZES.inspect}"
      end
      private_class_method :validate_size!
    end
  end
end
