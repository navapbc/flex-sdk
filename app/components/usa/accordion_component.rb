# frozen_string_literal: true

module USA
  # AccordionComponent renders a USWDS accordion with optional borders and multiselect.
  #
  # @example Basic usage
  #   <%= render USA::AccordionComponent.new(
  #     items: [
  #       { title: "First Amendment", content: "Congress shall make no law...", expanded: true },
  #       { title: "Second Amendment", content: "A well regulated Militia...", expanded: false }
  #     ]
  #   ) %>
  #
  # @example Bordered accordion
  #   <%= render USA::AccordionComponent.new(items: items, is_bordered: true) %>
  #
  # @example Multiselectable accordion
  #   <%= render USA::AccordionComponent.new(items: items, is_multiselectable: true) %>
  #
  class AccordionComponent < ViewComponent::Base
    def initialize(items:, is_bordered: false, is_multiselectable: false)
      @items = items
      @is_bordered = is_bordered
      @is_multiselectable = is_multiselectable
    end

    def accordion_classes
      classes = [ "usa-accordion" ]
      classes << "usa-accordion--bordered" if @is_bordered
      classes << "usa-accordion--multiselectable" if @is_multiselectable
      classes.join(" ")
    end

    def accordion_item_id(item, index)
      item[:id] || "accordion-item-#{index + 1}"
    end
  end
end
