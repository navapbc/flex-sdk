# frozen_string_literal: true

module Strata
  # ButtonsHelper provides thin view-helper wrappers around Rails' +link_to+ and
  # +button_to+ that apply USWDS button styling via Strata::US::ButtonComponent.
  #
  # @example A button-styled link
  #   <%= strata_link_to "Back", back_path, variant: :outline %>
  #
  # @example A destructive button_to with CSRF
  #   <%= strata_button_to "Delete", item_path(item), method: :delete, variant: :secondary %>
  #
  # @see Strata::US::ButtonComponent
  module ButtonsHelper
    # Renders a USWDS-styled button as an <a>. Accepts the same arguments as
    # Rails' +link_to+, plus +:variant+, +:size+, and +:inverse+ to control
    # the button styling. Any caller-supplied +:class+ is appended to the
    # USWDS classes.
    def strata_link_to(*args, variant: :default, size: :default, inverse: false, **html_options, &block)
      html_options = strata_button_html_options(html_options, variant: variant, size: size, inverse: inverse)
      link_to(*args, **html_options, &block)
    end

    # Renders a USWDS-styled button as a Rails-generated <form> + <button>.
    # Accepts the same arguments as Rails' +button_to+, plus +:variant+,
    # +:size+, and +:inverse+ to control the button styling. Any caller-supplied
    # +:class+ is appended to the USWDS classes.
    def strata_button_to(*args, variant: :default, size: :default, inverse: false, **html_options, &block)
      html_options = strata_button_html_options(html_options, variant: variant, size: size, inverse: inverse)
      button_to(*args, **html_options, &block)
    end

    private

    def strata_button_html_options(html_options, variant:, size:, inverse:)
      button_classes = Strata::US::ButtonComponent.css_classes(variant: variant, size: size, inverse: inverse)
      html_options[:class] = class_names(button_classes, html_options[:class])
      html_options
    end
  end
end
