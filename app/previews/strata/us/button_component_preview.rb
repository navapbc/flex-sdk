# frozen_string_literal: true

module Strata
  module US
    # ButtonComponentPreview provides preview examples for the Strata::US::ButtonComponent.
    class ButtonComponentPreview < Lookbook::Preview
      layout "strata/component_preview"

      # @label Default (primary)
      def default
        render Strata::US::ButtonComponent.new do
          "Default"
        end
      end

      # @label Secondary
      def secondary
        render Strata::US::ButtonComponent.new(variant: :secondary) do
          "Secondary"
        end
      end

      # @label Accent cool
      def accent_cool
        render Strata::US::ButtonComponent.new(variant: :accent_cool) do
          "Accent cool"
        end
      end

      # @label Accent warm
      def accent_warm
        render Strata::US::ButtonComponent.new(variant: :accent_warm) do
          "Accent warm"
        end
      end

      # @label Base
      def base
        render Strata::US::ButtonComponent.new(variant: :base) do
          "Base"
        end
      end

      # @label Outline
      def outline
        render Strata::US::ButtonComponent.new(variant: :outline) do
          "Outline"
        end
      end

      # @label Unstyled
      def unstyled
        render Strata::US::ButtonComponent.new(variant: :unstyled) do
          "Unstyled"
        end
      end

      # @label Big size
      def big
        render Strata::US::ButtonComponent.new(size: :big) do
          "Big primary"
        end
      end

      # @label Link styled as button
      def as_link
        render Strata::US::ButtonComponent.new(href: "#", variant: :outline) do
          "Outline link"
        end
      end

      # @label Submit-typed button
      def submit_type
        render Strata::US::ButtonComponent.new(type: :submit) do
          "Submit"
        end
      end

      # @label Disabled button
      def disabled
        render Strata::US::ButtonComponent.new(disabled: true) do
          "Disabled"
        end
      end

      # @label Disabled link
      def disabled_link
        render Strata::US::ButtonComponent.new(href: "#", disabled: true) do
          "Disabled link"
        end
      end
    end
  end
end
