# frozen_string_literal: true

module Strata
  module US
    # BreadcrumbsComponentPreview provides preview examples for the Strata::US::BreadcrumbsComponent.
    class BreadcrumbsComponentPreview < Lookbook::Preview
      layout "strata/component_preview"

      # @label Default
      def default
        render Strata::US::BreadcrumbsComponent.new do |bc|
          bc.with_item(href: "#") { "Home" }
          bc.with_item(href: "#") { "Cases" }
          bc.with_item { "Case #12345" }
        end
      end

      # @label Wrap variant
      def wrap
        render Strata::US::BreadcrumbsComponent.new(wrap: true) do |bc|
          bc.with_item(href: "#") { "Home" }
          bc.with_item(href: "#") { "Federal benefits" }
          bc.with_item(href: "#") { "Supplemental Nutrition Assistance Program" }
          bc.with_item(href: "#") { "Eligibility and how to apply" }
          bc.with_item { "Application #ABC-987654" }
        end
      end

      # @label Collection-passed items
      def from_collection
        render Strata::US::BreadcrumbsComponent.new do |bc|
          bc.with_items([
            { text: "Home", href: "#" },
            { text: "Cases", href: "#" },
            { text: "Case #12345" }
          ])
        end
      end

      # @label Single current page
      def single_item
        render Strata::US::BreadcrumbsComponent.new do |bc|
          bc.with_item { "Home" }
        end
      end

      # @label Custom aria-label
      def custom_aria_label
        render Strata::US::BreadcrumbsComponent.new(aria_label: "You are here") do |bc|
          bc.with_item(href: "#") { "Home" }
          bc.with_item(href: "#") { "Account" }
          bc.with_item { "Profile" }
        end
      end
    end
  end
end
