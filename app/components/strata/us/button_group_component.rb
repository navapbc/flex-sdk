# frozen_string_literal: true

module Strata
  module US
    # ButtonGroupComponent renders a USWDS button group: a <ul class="usa-button-group">
    # whose children are <li class="usa-button-group__item"> wrappers containing
    # whatever button-styled element the caller chooses (a Strata::US::ButtonComponent,
    # a link_to, an f.submit, etc.).
    #
    # See https://designsystem.digital.gov/components/button-group/.
    #
    # @example Default
    #   <%= render Strata::US::ButtonGroupComponent.new do |group| %>
    #     <% group.with_item do %>
    #       <%= render Strata::US::ButtonComponent.new do %>Save<% end %>
    #     <% end %>
    #     <% group.with_item do %>
    #       <%= link_to "Cancel", cancel_path,
    #             class: Strata::US::ButtonComponent.css_classes(variant: :outline) %>
    #     <% end %>
    #   <% end %>
    #
    # @example Segmented
    #   <%= render Strata::US::ButtonGroupComponent.new(segmented: true) do |group| %>
    #     <% group.with_item { ... } %>
    #     <% group.with_item { ... } %>
    #   <% end %>
    class ButtonGroupComponent < ViewComponent::Base
      renders_many :items, "Strata::US::ButtonGroupComponent::ItemComponent"

      def initialize(segmented: false, classes: nil, **html_attributes)
        @segmented = segmented
        @classes = classes
        @html_attributes = html_attributes
      end

      def wrapper_classes
        class_names(
          "usa-button-group",
          { "usa-button-group--segmented" => @segmented },
          @classes
        )
      end

      def list_attributes
        attrs = @html_attributes.dup
        attrs[:class] = wrapper_classes
        attrs
      end

      # ItemComponent renders one entry as an <li class="usa-button-group__item">.
      class ItemComponent < ViewComponent::Base
        def initialize(classes: nil, **html_attributes)
          @classes = classes
          @html_attributes = html_attributes
        end

        def call
          attrs = @html_attributes.dup
          attrs[:class] = class_names("usa-button-group__item", @classes)

          content_tag(:li, content, **attrs)
        end
      end
    end
  end
end
