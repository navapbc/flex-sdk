# frozen_string_literal: true

module Strata
  module US
    # AccordionComponentPreview provides preview examples for the Strata::US::AccordionComponent.
    class AccordionComponentPreview < Lookbook::Preview
      layout "component_preview"

      def borderless
        render Strata::US::AccordionComponent.new(heading_tag: :h4) do |component|
          component.with_heading { "First Amendment" }
          component.with_body { "<p>Congress shall make no law respecting an establishment of religion, or prohibiting the free exercise thereof; or abridging the freedom of speech, or of the press; or the right of the people peaceably to assemble, and to petition the Government for a redress of grievances.</p>".html_safe }
          component.with_heading { "Second Amendment" }
          component.with_body { "<p>A well regulated Militia, being necessary to the security of a free State, the right of the people to keep and bear Arms, shall not be infringed.</p><ul><li>This is a list item</li><li>Another list item</li></ul>".html_safe }
          component.with_heading { "Third Amendment" }
          component.with_body { "<p>No Soldier shall, in time of peace be quartered in any house, without the consent of the Owner, nor in time of war, but in a manner to be prescribed by law.</p>".html_safe }
        end
      end

      def bordered
        render Strata::US::AccordionComponent.new(heading_tag: :h4, is_bordered: true) do |component|
          component.with_heading { "First Amendment" }
          component.with_body { "<p>Congress shall make no law respecting an establishment of religion, or prohibiting the free exercise thereof; or abridging the freedom of speech, or of the press; or the right of the people peaceably to assemble, and to petition the Government for a redress of grievances.</p>".html_safe }
          component.with_heading { "Second Amendment" }
          component.with_body { "<p>A well regulated Militia, being necessary to the security of a free State, the right of the people to keep and bear Arms, shall not be infringed.</p><ul><li>This is a list item</li><li>Another list item</li></ul>".html_safe }
          component.with_heading { "Third Amendment" }
          component.with_body { "<p>No Soldier shall, in time of peace be quartered in any house, without the consent of the Owner, nor in time of war, but in a manner to be prescribed by law.</p>".html_safe }
        end
      end

      def multiselectable
        render Strata::US::AccordionComponent.new(heading_tag: :h4, is_multiselectable: true) do |component|
          component.with_heading { "First Amendment" }
          component.with_body { "<p>Congress shall make no law respecting an establishment of religion, or prohibiting the free exercise thereof; or abridging the freedom of speech, or of the press; or the right of the people peaceably to assemble, and to petition the Government for a redress of grievances.</p>".html_safe }
          component.with_heading { "Second Amendment" }
          component.with_body { "<p>A well regulated Militia, being necessary to the security of a free State, the right of the people to keep and bear Arms, shall not be infringed.</p><ul><li>This is a list item</li><li>Another list item</li></ul>".html_safe }
          component.with_heading { "Third Amendment" }
          component.with_body { "<p>No Soldier shall, in time of peace be quartered in any house, without the consent of the Owner, nor in time of war, but in a manner to be prescribed by law.</p>".html_safe }
        end
      end
    end
  end
end
