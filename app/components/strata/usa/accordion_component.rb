# frozen_string_literal: true

module Strata
  module USA
    # AccordionComponent renders a USWDS accordion with optional borders and multiselect.
    #
    # @example Basic usage
    #   <%= render Strata::USA::AccordionComponent.new do |component| %>
    #     <% component.with_heading(expanded: true, controls: "a1") { "First Amendment" } %>
    #     <% component.with_body(id: "a1") { "<p>Congress shall make no law...</p>".html_safe } %>
    #     <% component.with_heading(expanded: false, controls: "a2") { "Second Amendment" } %>
    #     <% component.with_body(id: "a2") { "<p>A well regulated Militia...</p>".html_safe } %>
    #   <% end %>
    #
    class AccordionComponent < ViewComponent::Base
      class Heading < ViewComponent::Base
        attr_reader :heading_tag, :expanded, :controls

        def initialize(heading_tag: "h4", expanded: false, controls:)
          @heading_tag = heading_tag
          @expanded = expanded
          @controls = controls
        end

        def call
          content_tag heading_tag, class: "usa-accordion__heading" do
            content_tag :button, type: "button", class: "usa-accordion__button",
                        aria: { expanded: expanded.to_s, controls: controls } do
              content
            end
          end
        end
      end

      class Body < ViewComponent::Base
        attr_reader :id

        def initialize(id:)
          @id = id
        end

        def call
          content_tag :div, id: id, class: "usa-accordion__content usa-prose" do
            content
          end
        end
      end

      renders_many :headings, Heading
      renders_many :bodies, Body

      def initialize(is_bordered: false, is_multiselectable: false)
        @is_bordered = is_bordered
        @is_multiselectable = is_multiselectable
      end

      def before_render
        if headings.length != bodies.length
          raise ArgumentError, "Number of headings (#{headings.length}) must match number of bodies (#{bodies.length})"
        end
      end
    end
  end
end
