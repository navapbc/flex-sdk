# frozen_string_literal: true

module Strata
  # LinksHelper provides Strata's view-helper wrappers around Rails' +link_to+.
  # The helper defaults to a passthrough; pass +:as+ to opt into a styling
  # treatment (+:button+ for USWDS button styling, +:external+ for the USWDS
  # external-link styling).
  #
  # @example A plain link (passthrough)
  #   <%= strata_link_to "Read more", article_path %>
  #
  # @example A button-styled link
  #   <%= strata_link_to "Back", root_path, as: :button, variant: :outline %>
  #
  # @example A USWDS external link
  #   <%= strata_link_to "Read the docs", "https://example.gov", as: :external %>
  #
  # @see Strata::US::ButtonComponent
  # @see Strata::US::LinkComponent
  module LinksHelper
    # Allowed values for the +:as+ keyword on +strata_link_to+.
    STRATA_LINK_TREATMENTS = %i[button external].freeze

    # Renders a Rails +link_to+ with an optional Strata styling treatment
    # controlled by the +:as+ keyword. Without +:as+, it's a pure passthrough.
    #
    # With +as: :button+, applies USWDS button styling via
    # Strata::US::ButtonComponent.css_classes and accepts +:variant+, +:size+,
    # and +:inverse+.
    #
    # With +as: :external+, applies USWDS external-link styling via
    # Strata::US::LinkComponent.css_classes and accepts +:alt+ for the
    # dark-background variant. Styling only — pass +target:+ / +rel:+
    # explicitly if you want the link to open in a new tab.
    #
    # A caller-supplied +:class+ is appended to the treatment's classes.
    #
    # Raises ArgumentError if +:as+ is unrecognized, or if +:variant+/+:size+/
    # +:inverse+ are passed without +as: :button+.
    def strata_link_to(*args, as: nil, **html_options, &block)
      button_kwargs = html_options.extract!(:variant, :size, :inverse)
      link_kwargs = html_options.extract!(:alt)

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
      when :external
        link_classes = Strata::US::LinkComponent.css_classes(external: true, **link_kwargs)
        html_options[:class] = class_names(link_classes, html_options[:class])
        link_to(*args, **html_options, &block)
      else
        raise ArgumentError,
              "Invalid :as value: #{as.inspect}. Must be one of #{STRATA_LINK_TREATMENTS.inspect} or omitted."
      end
    end
  end
end
