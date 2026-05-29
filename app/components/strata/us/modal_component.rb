# frozen_string_literal: true

module Strata
  module US
    # ModalComponent renders a USWDS modal — a dialog that interrupts the page
    # to require attention or confirmation.
    #
    # See https://designsystem.digital.gov/components/modal/.
    #
    # Pair the modal with an opener element elsewhere on the page. Use
    # +strata_link_to+ with the +modal:+ keyword for the canonical case, or
    # splat +Strata::US::ModalComponent.opener_attrs(id)+ onto any tag helper
    # when an anchor isn't possible (e.g. inside an existing +<form>+).
    #
    # All three slots — heading, content, footer — are optional. The
    # +aria-labelledby+ / +aria-describedby+ attributes on the wrapper are
    # only emitted when their corresponding slot is rendered.
    #
    # @example Basic usage
    #   <%= render Strata::US::ModalComponent.new(id: "confirm") do |modal| %>
    #     <% modal.with_heading { "Are you sure?" } %>
    #     <% modal.with_content { "<p>This cannot be undone.</p>".html_safe } %>
    #     <% modal.with_footer do %>
    #       <%= render Strata::US::ButtonGroupComponent.new do |group| %>
    #         <% group.with_item do %>
    #           <%= render Strata::US::ButtonComponent.new(data: { close_modal: "" }) { "Continue" } %>
    #         <% end %>
    #       <% end %>
    #     <% end %>
    #   <% end %>
    #
    #   <%= strata_link_to "Open modal", modal: "confirm", as: :button %>
    #
    # @example Large + forced-action modal (no close button)
    #   <%= render Strata::US::ModalComponent.new(id: "blocking", large: true, forced_action: true) do |m| %>
    #     <% m.with_heading { "Session expiring" } %>
    #     <% m.with_content { "<p>You'll be signed out in 30 seconds.</p>".html_safe } %>
    #   <% end %>
    class ModalComponent < ViewComponent::Base
      renders_one :heading
      renders_one :content_section
      renders_one :footer

      def initialize(
        id:,
        heading_tag: :h2,
        large: false,
        forced_action: false,
        classes: nil,
        **html_attributes
      )
        raise ArgumentError, "ModalComponent requires a non-blank id" if id.blank?

        @id = id
        @heading_tag = heading_tag
        @large = large
        @forced_action = forced_action
        @classes = classes
        @html_attributes = html_attributes
      end

      # The user-facing slot name is +with_content+ (matching the USWDS
      # description-region concept). Internally the slot is named
      # +content_section+ to avoid colliding with ViewComponent's implicit
      # +content+ accessor.
      def with_content(&block)
        with_content_section(&block)
      end

      # Returns the HTML attribute hash that turns any element into a USWDS
      # modal opener for the modal with the given id. Splat onto any tag
      # helper:
      #
      #   <%= link_to "Open", **Strata::US::ModalComponent.opener_attrs("confirm") %>
      #   <%= button_tag "Open", **Strata::US::ModalComponent.opener_attrs("confirm") %>
      #
      # +href: "#id"+ is included for graceful degradation: anchor elements
      # jump to the modal's content when JS is off; tag helpers that don't
      # render +href+ drop it.
      def self.opener_attrs(id)
        raise ArgumentError, "ModalComponent.opener_attrs requires a non-blank id" if id.blank?

        {
          href: "##{id}",
          "aria-controls": id,
          "data-open-modal": ""
        }
      end

      def wrapper_attributes
        attrs = @html_attributes.dup
        attrs[:class] = wrapper_classes
        attrs[:id] = @id
        attrs[:"aria-labelledby"] = heading_id if heading?
        attrs[:"aria-describedby"] = description_id if content_section?
        attrs[:"data-force-action"] = "" if @forced_action
        attrs
      end

      def wrapper_classes
        class_names(
          "usa-modal",
          { "usa-modal--lg" => @large },
          @classes
        )
      end

      def heading_id
        "#{@id}-heading"
      end

      def description_id
        "#{@id}-description"
      end

      def close_aria_label
        I18n.t("strata.components.us.modal.close_aria_label")
      end

      def show_close_button?
        !@forced_action
      end
    end
  end
end
