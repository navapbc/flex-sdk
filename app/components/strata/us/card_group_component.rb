# frozen_string_literal: true

module Strata
  module US
    # CardGroupComponent renders a USWDS card group — a <ul> wrapper around multiple cards
    # rendered as <li> elements.
    #
    # @example Basic usage
    #   <%= render Strata::US::CardGroupComponent.new do |group| %>
    #     <% group.with_card do |card| %>
    #       <% card.with_header { "First card" } %>
    #       <% card.with_body { "Body" } %>
    #     <% end %>
    #     <% group.with_card do |card| %>
    #       <% card.with_header { "Second card" } %>
    #       <% card.with_body { "Body" } %>
    #     <% end %>
    #   <% end %>
    class CardGroupComponent < ViewComponent::Base
      renders_many :cards, ->(**options) { CardComponent.new(**options.merge(tag: :li)) }

      def initialize(classes: nil, **html_attributes)
        @classes = classes
        @html_attributes = html_attributes
      end

      def group_classes
        class_names("usa-card-group", @classes)
      end
    end
  end
end
