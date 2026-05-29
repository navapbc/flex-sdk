# frozen_string_literal: true

module Strata
  module US
    # ModalComponentPreview shows the Strata::US::ModalComponent in its common
    # configurations. Lookbook only renders the modal markup itself (no
    # JavaScript-driven open/close) — the previews include a button-styled
    # opener anchor so the relationship between trigger and dialog is visible.
    class ModalComponentPreview < Lookbook::Preview
      layout "strata/component_preview"

      HEADING_TAGS = %w[h1 h2 h3 h4 h5 h6].freeze

      # @label Playground
      # @param id text
      # @param heading text
      # @param body textarea
      # @param footer_button_label text
      # @param large toggle
      # @param forced_action toggle
      # @param heading_tag select { choices: [h1, h2, h3, h4, h5, h6] }
      def playground(
        id: "playground-modal",
        heading: "Are you sure?",
        body: "Your changes will be lost if you leave this page without saving. Are you sure you want to continue?",
        footer_button_label: "Continue without saving",
        large: false,
        forced_action: false,
        heading_tag: "h2"
      )
        render_with_template(
          locals: {
            id: id,
            heading: heading,
            body: body,
            footer_button_label: footer_button_label,
            large: large,
            forced_action: forced_action,
            heading_tag: HEADING_TAGS.include?(heading_tag.to_s) ? heading_tag.to_sym : :h2
          }
        )
      end

      # @label Basic
      def basic
        render Strata::US::ModalComponent.new(id: "basic-modal") do |m|
          m.with_heading { "You have unsaved changes" }
          m.with_content do
            "<p>Your changes will be lost if you leave this page without saving.</p>".html_safe
          end
          m.with_footer do
            render(Strata::US::ButtonGroupComponent.new) do |group|
              group.with_item do
                render(Strata::US::ButtonComponent.new(data: { close_modal: "" })) { "Continue" }
              end
              group.with_item do
                render(Strata::US::ButtonComponent.new(variant: :unstyled, data: { close_modal: "" })) { "Go back" }
              end
            end
          end
        end
      end

      # @label Large
      def large
        render Strata::US::ModalComponent.new(id: "large-modal", large: true) do |m|
          m.with_heading { "Modal heading" }
          m.with_content do
            "<p>The large variant gives more room for longer body content or denser UI elements.</p>".html_safe
          end
          m.with_footer do
            render(Strata::US::ButtonGroupComponent.new) do |group|
              group.with_item do
                render(Strata::US::ButtonComponent.new(data: { close_modal: "" })) { "OK" }
              end
            end
          end
        end
      end

      # @label Forced action (no close button)
      def forced_action
        render Strata::US::ModalComponent.new(id: "forced-modal", forced_action: true) do |m|
          m.with_heading { "Session expiring" }
          m.with_content do
            "<p>You'll be signed out in 30 seconds. Choose an option to continue.</p>".html_safe
          end
          m.with_footer do
            render(Strata::US::ButtonGroupComponent.new) do |group|
              group.with_item do
                render(Strata::US::ButtonComponent.new(data: { close_modal: "" })) { "Stay signed in" }
              end
              group.with_item do
                render(Strata::US::ButtonComponent.new(variant: :secondary, data: { close_modal: "" })) { "Sign out" }
              end
            end
          end
        end
      end
    end
  end
end
