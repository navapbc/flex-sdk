# frozen_string_literal: true

module Strata
  module US
    # ButtonGroupComponent renders a USWDS button group: a <ul class="usa-button-group">
    # whose children are <li> wrappers containing whatever button-styled element
    # the caller chooses (a Strata::US::ButtonComponent, a link_to, an f.submit, etc.).
    #
    # The <li>s deliberately do *not* carry the `usa-button-group__item` class in
    # the default variant. That class triggers a known USWDS bug where buttons
    # inside a `.usa-form` render too tall — see
    # https://github.com/uswds/uswds/issues/5883. The class is applied only in
    # the segmented variant, where its CSS hooks (border rounding, connector
    # pseudo-elements) are required for the visual treatment.
    #
    # See https://designsystem.digital.gov/components/button-group/.
    #
    # @example Default
    #   <%= render Strata::US::ButtonGroupComponent.new do |group| %>
    #     <% group.with_item do %>
    #       <%= render Strata::US::ButtonComponent.new do %>Save<% end %>
    #     <% end %>
    #     <% group.with_item do %>
    #       <%= strata_link_to "Cancel", cancel_path, as: :button, variant: :outline %>
    #     <% end %>
    #   <% end %>
    #
    # @example Segmented
    #   <%= render Strata::US::ButtonGroupComponent.new(segmented: true) do |group| %>
    #     <% group.with_item { ... } %>
    #     <% group.with_item { ... } %>
    #   <% end %>
    class ButtonGroupComponent < ViewComponent::Base
      renders_many :items, ->(**kwargs) {
        ItemComponent.new(segmented: @segmented, **kwargs)
      }

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

      # ItemComponent renders one entry as an <li>. The `usa-button-group__item`
      # class is applied only when the parent group is segmented; see the
      # ButtonGroupComponent comment above for the rationale (USWDS issue 5883).
      class ItemComponent < ViewComponent::Base
        def initialize(segmented: false, classes: nil, **html_attributes)
          @segmented = segmented
          @classes = classes
          @html_attributes = html_attributes
        end

        def call
          attrs = @html_attributes.dup
          base_class = "usa-button-group__item" if @segmented
          combined = class_names(base_class, @classes)
          attrs[:class] = combined if combined.present?

          content_tag(:li, content, **attrs)
        end
      end
    end
  end
end
