# frozen_string_literal: true

module Strata
  module US
    # ListComponentPreview provides preview examples for the Strata::US::ListComponent.
    class ListComponentPreview < Lookbook::Preview
      layout "strata/component_preview"

      # @label Unordered List
      def unordered
        render Strata::US::ListComponent.new do |list|
          list.with_item { "Unordered list item" }
          list.with_item { "Unordered list item" }
          list.with_item { "Unordered list item" }
        end
      end

      # @label Ordered List
      def ordered
        render Strata::US::ListComponent.new(ordered: true) do |list|
          list.with_item { "Ordered list item" }
          list.with_item { "Ordered list item" }
          list.with_item { "Ordered list item" }
        end
      end

      # @label Unstyled List
      def unstyled
        render Strata::US::ListComponent.new(unstyled: true) do |list|
          list.with_item { "Unstyled list item" }
          list.with_item { "Unstyled list item" }
          list.with_item { "Unstyled list item" }
        end
      end

      # @label Collection-passed Items
      def from_collection
        render Strata::US::ListComponent.new do |list|
          list.with_items([ "Apples", "Bananas", "Cherries", "Dates" ])
        end
      end

      # @label Nested List
      # Renders via the sibling `nested.html.erb` template — nested `render` calls don't work inside slot blocks in a Lookbook preview method.
      def nested; end
    end
  end
end
