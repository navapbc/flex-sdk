# frozen_string_literal: true

module Strata
  module US
    # BreadcrumbsComponent renders a USWDS breadcrumb trail.
    # See https://designsystem.digital.gov/components/breadcrumb/.
    #
    # The last item is always rendered as the current page (no link,
    # `usa-current` + `aria-current="page"`) regardless of whether an
    # `href` was supplied.
    #
    # @example Slot style
    #   <%= render Strata::US::BreadcrumbsComponent.new do |bc| %>
    #     <% bc.with_item(href: root_path) { "Home" } %>
    #     <% bc.with_item(href: cases_path) { "Cases" } %>
    #     <% bc.with_item { "Case #12345" } %>
    #   <% end %>
    #
    # @example Collection style
    #   <%= render Strata::US::BreadcrumbsComponent.new do |bc| %>
    #     <% bc.with_items([
    #          { text: "Home", href: root_path },
    #          { text: "Cases", href: cases_path },
    #          { text: "Case #12345" }
    #        ]) %>
    #   <% end %>
    class BreadcrumbsComponent < ViewComponent::Base
      renders_many :items, "Strata::US::BreadcrumbsComponent::ItemComponent"

      def initialize(wrap: false, aria_label: nil, classes: nil, **html_attributes)
        @wrap = wrap
        @aria_label = aria_label || I18n.t("strata.components.us.breadcrumbs.aria_label")
        @classes = classes
        @html_attributes = html_attributes
      end

      def before_render
        items.last&.current!
      end

      def wrapper_classes
        class_names(
          "usa-breadcrumb",
          { "usa-breadcrumb--wrap" => @wrap },
          @classes
        )
      end

      def nav_attributes
        attrs = @html_attributes.dup
        attrs[:class] = wrapper_classes
        attrs[:"aria-label"] = @aria_label
        attrs
      end

      # ItemComponent renders one crumb as an <li>. The parent marks the
      # final crumb via `current!` so it renders as the current page
      # (no link, `usa-current` + `aria-current="page"`) regardless of any
      # `href` that was supplied.
      class ItemComponent < ViewComponent::Base
        def initialize(text = nil, **opts)
          @text = text || opts.delete(:text)
          @href = opts.delete(:href)
          @classes = opts.delete(:classes)
          @html_attributes = opts
          @current = false
        end

        def current!
          @current = true
        end

        def call
          attrs = @html_attributes.dup
          attrs[:class] = class_names(
            "usa-breadcrumb__list-item",
            { "usa-current" => @current },
            @classes
          )
          attrs[:"aria-current"] = "page" if @current

          content_tag(:li, **attrs) { inner_content }
        end

        private

        def inner_content
          text = content.presence || @text
          if @current || @href.blank?
            content_tag(:span, text)
          else
            link_to(@href, class: "usa-breadcrumb__link") { content_tag(:span, text) }
          end
        end
      end
    end
  end
end
