# frozen_string_literal: true

module Strata
  module USA
    # AccordionComponentPreview provides preview examples for the Strata::USA::AccordionComponent.
    class AccordionComponentPreview < Lookbook::Preview
      layout "component_preview"

      def borderless
        render Strata::USA::AccordionComponent.new(
          is_bordered: false,
          is_multiselectable: false
        ) do |component|
          amendment_items.each do |item|
            component.with_heading(expanded: item[:expanded], controls: item[:id]) { item[:title] }
            component.with_body(id: item[:id]) { item[:content] }
          end
        end
      end

      def bordered
        render Strata::USA::AccordionComponent.new(
          is_bordered: true,
          is_multiselectable: false
        ) do |component|
          amendment_items.each do |item|
            component.with_heading(expanded: item[:expanded], controls: item[:id]) { item[:title] }
            component.with_body(id: item[:id]) { item[:content] }
          end
        end
      end

      def multiselectable
        render Strata::USA::AccordionComponent.new(
          is_bordered: false,
          is_multiselectable: true
        ) do |component|
          amendment_items.each do |item|
            component.with_heading(expanded: item[:expanded], controls: item[:id]) { item[:title] }
            component.with_body(id: item[:id]) { item[:content] }
          end
        end
      end

      private

      def amendment_items
        [
          {
            id: "a1",
            title: "First Amendment",
            content: "<p>Congress shall make no law respecting an establishment of religion, or prohibiting the free exercise thereof; or abridging the freedom of speech, or of the press; or the right of the people peaceably to assemble, and to petition the Government for a redress of grievances.</p>".html_safe,
            expanded: true
          },
          {
            id: "a2",
            title: "Second Amendment",
            content: "<p>A well regulated Militia, being necessary to the security of a free State, the right of the people to keep and bear Arms, shall not be infringed.</p><ul><li>This is a list item</li><li>Another list item</li></ul>".html_safe,
            expanded: false
          },
          {
            id: "a3",
            title: "Third Amendment",
            content: "<p>No Soldier shall, in time of peace be quartered in any house, without the consent of the Owner, nor in time of war, but in a manner to be prescribed by law.</p>".html_safe,
            expanded: false
          },
          {
            id: "a4",
            title: "Fourth Amendment",
            content: "<p>The right of the people to be secure in their persons, houses, papers, and effects, against unreasonable searches and seizures, shall not be violated, and no Warrants shall issue, but upon probable cause, supported by Oath or affirmation, and particularly describing the place to be searched, and the persons or things to be seized.</p>".html_safe,
            expanded: false
          },
          {
            id: "a5",
            title: "Fifth Amendment",
            content: "<p>No person shall be held to answer for a capital, or otherwise infamous crime, unless on a presentment or indictment of a Grand Jury, except in cases arising in the land or naval forces, or in the Militia, when in actual service in time of War or public danger; nor shall any person be subject for the same offence to be twice put in jeopardy of life or limb; nor shall be compelled in any criminal case to be a witness against himself, nor be deprived of life, liberty, or property, without due process of law; nor shall private property be taken for public use, without just compensation.</p>".html_safe,
            expanded: false
          }
        ]
      end
    end
  end
end
