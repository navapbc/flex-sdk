# frozen_string_literal: true

module Strata
  # ButtonsHelper provides Strata's view-helper wrapper around Rails' +button_to+
  # that applies USWDS styling via Strata::US::ButtonComponent.
  #
  # For button-styled links (+<a>+) — i.e. GET navigation that *looks* like a
  # button — use +strata_link_to ..., as: :button+ in Strata::LinksHelper.
  #
  # @example A destructive button_to with CSRF
  #   <%= strata_button_to "Delete", item_path(item), method: :delete, variant: :secondary %>
  #
  # @see Strata::US::ButtonComponent
  # @see Strata::LinksHelper
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
