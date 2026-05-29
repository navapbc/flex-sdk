# frozen_string_literal: true

module Strata
  module US
    # LinkComponent renders a USWDS-styled <a>. The component applies styling
    # only — it does not set +target+ or +rel+. Callers that want to open a
    # link in a new tab should pass +target: "_blank"+ and
    # +rel: "noopener noreferrer"+ explicitly.
    #
    # See https://designsystem.digital.gov/components/link/.
    #
    # The +strata_link_to+ view helper (see Strata::LinksHelper) wraps Rails'
    # +link_to+ and applies this styling for Rails-rendered tags via the
    # +as: :external+ treatment. For other call sites, pass
    # +Strata::US::LinkComponent.css_classes+ as the +:class+. The class-method
    # helper is the single source of truth.
    #
    # @example A plain styled link
    #   <%= render Strata::US::LinkComponent.new(href: article_path) do %>
    #     Read more
    #   <% end %>
    #
    # @example An external link (caller-controlled target/rel)
    #   <%= render Strata::US::LinkComponent.new(
    #         href: "https://example.gov",
    #         external: true,
    #         target: "_blank",
    #         rel: "noopener noreferrer") do %>
    #     example.gov
    #   <% end %>
    #
    # @example The view helper
    #   <%= strata_link_to "Read more", "https://example.gov", as: :external %>
    class LinkComponent < ViewComponent::Base
      def initialize(
        href:,
        external: false,
        alt: false,
        classes: nil,
        **html_attributes
      )
        @href = href
        @external = external
        @alt = alt
        @classes = classes
        @html_attributes = html_attributes
      end

      # Returns the USWDS class string for a link-styled element, without
      # rendering the element itself. Use this for +link_to+ and other call
      # sites where Rails owns the tag.
      #
      # +alt: true+ without +external: true+ is a no-op — +usa-link--alt+ is
      # only meaningful in combination with +usa-link--external+.
      def self.css_classes(external: false, alt: false)
        parts = [ "usa-link" ]
        parts << "usa-link--external" if external
        parts << "usa-link--alt" if external && alt
        parts.join(" ")
      end

      def element_attributes
        attrs = @html_attributes.dup
        attrs[:class] = combined_classes
        attrs[:href] = @href
        attrs
      end

      private

      def combined_classes
        base = self.class.css_classes(external: @external, alt: @alt)
        @classes.present? ? "#{base} #{@classes}" : base
      end
    end
  end
end
