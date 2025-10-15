# frozen_string_literal: true

module Strata
  module US
    # AccordionComponent renders a USWDS accordion with optional borders and multiselect.
    #
    # @example Basic usage
    #   <%= render Strata::US::AccordionComponent.new do |component| %>
    #     <% component.with_heading(expanded: true, controls: "a1") { "First Amendment" } %>
    #     <% component.with_body(id: "a1") { "<p>Congress shall make no law...</p>".html_safe } %>
    #     <% component.with_heading(expanded: false, controls: "a2") { "Second Amendment" } %>
    #     <% component.with_body(id: "a2") { "<p>A well regulated Militia...</p>".html_safe } %>
    #   <% end %>
    #
    class AccordionComponent < ViewComponent::Base
      renders_many :headings
      renders_many :bodies

      def initialize(heading_tag:, id_prefix: nil, is_bordered: false, is_multiselectable: false)
        @heading_tag = heading_tag
        @is_bordered = is_bordered
        @is_multiselectable = is_multiselectable
        @id_prefix = id_prefix || "acrdn-#{SecureRandom.hex(6)}-"
      end

      def before_render
        if headings.length != bodies.length
          raise ArgumentError, "Number of headings (#{headings.length}) must match number of bodies (#{bodies.length})"
        end
      end

      private

      def item_id(idx)
        "#{@id_prefix}#{idx + 1}"
      end
    end
  end
end
