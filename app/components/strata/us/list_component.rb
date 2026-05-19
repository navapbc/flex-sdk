# frozen_string_literal: true

module Strata
  module US
    # ListComponent renders a USWDS-styled list as either a <ul> or <ol>,
    # with optional unstyled (no markers, no indent) modifier.
    #
    # @example Basic unordered list
    #   <%= render Strata::US::ListComponent.new do |list| %>
    #     <% list.with_item { "First" } %>
    #     <% list.with_item { "Second" } %>
    #   <% end %>
    #
    # @example Ordered list
    #   <%= render Strata::US::ListComponent.new(ordered: true) do |list| %>
    #     <% list.with_item { "First" } %>
    #   <% end %>
    #
    # @example Passing a collection of items
    #   <%= render Strata::US::ListComponent.new do |list| %>
    #     <% list.with_items(["Apples", "Bananas", "Cherries"]) %>
    #   <% end %>
    #
    # @example Unstyled (no markers, no indent)
    #   <%= render Strata::US::ListComponent.new(unstyled: true) do |list| %>
    #     <% list.with_item { "First" } %>
    #   <% end %>
    class ListComponent < ViewComponent::Base
      renders_many :items, "Strata::US::ListComponent::ItemComponent"

      def initialize(ordered: false, unstyled: false, classes: nil, **html_attributes)
        @ordered = ordered
        @unstyled = unstyled
        @classes = classes
        @html_attributes = html_attributes
      end

      def list_tag
        @ordered ? :ol : :ul
      end

      def list_classes
        class_names(
          "usa-list",
          { "usa-list--unstyled" => @unstyled },
          @classes
        )
      end

      # Renders an individual list item (<li>). Accepts content as a positional
      # argument (used by ViewComponent's collection-passing via `with_items`)
      # or as a block (used by `with_item { ... }`).
      class ItemComponent < ViewComponent::Base
        def initialize(text = nil, classes: nil, **html_attributes)
          @text = text
          @classes = classes
          @html_attributes = html_attributes
        end

        def call
          content_tag :li, (content || @text), class: @classes, **@html_attributes
        end
      end
    end
  end
end
