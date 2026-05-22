# frozen_string_literal: true

module Strata
  # ButtonsHelper provides view-helper wrappers around Rails' link/button
  # primitives that apply USWDS styling treatments via
  # Strata::US::ButtonComponent.
  #
  # @example A plain link (passthrough)
  #   <%= strata_link_to "Read more", article_path %>
  #
  # @example A button-styled link
  #   <%= strata_link_to "Back", root_path, as: :button, variant: :outline %>
  #
  # @example A destructive button_to with CSRF
  #   <%= strata_button_to "Delete", item_path(item), method: :delete, variant: :secondary %>
  #
  # @see Strata::US::ButtonComponent
  module ButtonsHelper
    # Allowed values for the +:as+ keyword on +strata_link_to+. Currently the
    # only treatment is +:button+, but the contract is open to other treatments
    # later (e.g. +:external+).
    STRATA_LINK_TREATMENTS = %i[button].freeze

    # Renders a Rails +link_to+ with an optional Strata styling treatment
    # controlled by the +:as+ keyword. Without +:as+, it's a pure passthrough.
    # With +as: :button+, applies USWDS button styling via
    # Strata::US::ButtonComponent.css_classes and accepts +:variant+, +:size+,
    # and +:inverse+ to control the styling. A caller-supplied +:class+ is
    # appended to the treatment's classes.
    #
    # Raises ArgumentError if +:as+ is unrecognized, or if +:variant+/+:size+/
    # +:inverse+ are passed without +as: :button+.
    def strata_link_to(*args, as: nil, **html_options, &block)
      button_kwargs = html_options.extract!(:variant, :size, :inverse)

      case as
      when nil
        unless button_kwargs.empty?
          raise ArgumentError,
                "strata_link_to received #{button_kwargs.keys.inspect} but no `as: :button`. " \
                "Either pass `as: :button` or remove these keywords."
        end
        link_to(*args, **html_options, &block)
      when :button
        button_classes = Strata::US::ButtonComponent.css_classes(**button_kwargs)
        html_options[:class] = class_names(button_classes, html_options[:class])
        link_to(*args, **html_options, &block)
      else
        raise ArgumentError,
              "Invalid :as value: #{as.inspect}. Must be one of #{STRATA_LINK_TREATMENTS.inspect} or omitted."
      end
    end

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
