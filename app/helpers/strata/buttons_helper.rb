# frozen_string_literal: true

module Strata
  # ButtonsHelper provides view-helper wrappers around Rails' button-producing
  # primitives that apply USWDS button styling via Strata::US::ButtonComponent.
  #
  # Note: there is intentionally no +strata_link_to+ — a generic +link_to+
  # should not always imply button styling. For button-styled anchors, render
  # +Strata::US::ButtonComponent+ with +href:+, or pass
  # +Strata::US::ButtonComponent.css_classes(...)+ as the +:class+ on a regular
  # +link_to+.
  #
  # @example A destructive button_to with CSRF
  #   <%= strata_button_to "Delete", item_path(item), method: :delete, variant: :secondary %>
  #
  # @see Strata::US::ButtonComponent
  module ButtonsHelper
    # Renders a USWDS-styled button as a Rails-generated <form> + <button>.
    # Accepts the same arguments as Rails' +button_to+, plus +:variant+,
    # +:size+, and +:inverse+ to control the button styling. Any caller-supplied
    # +:class+ is appended to the USWDS classes.
    def strata_button_to(*args, variant: :default, size: :default, inverse: false, **html_options, &block)
      button_classes = Strata::US::ButtonComponent.css_classes(variant: variant, size: size, inverse: inverse)
      html_options[:class] = class_names(button_classes, html_options[:class])
      button_to(*args, **html_options, &block)
    end
  end
end
