# frozen_string_literal: true

module Strata
  module US
    # ButtonGroupComponentPreview provides preview examples for the Strata::US::ButtonGroupComponent.
    class ButtonGroupComponentPreview < Lookbook::Preview
      layout "strata/component_preview"

      # @label Default
      def default
        render Strata::US::ButtonGroupComponent.new do |group|
          group.with_item do
            %(<button class="#{Strata::US::ButtonComponent.css_classes}">Save</button>).html_safe
          end
          group.with_item do
            %(<button class="#{Strata::US::ButtonComponent.css_classes(variant: :outline)}">Cancel</button>).html_safe
          end
        end
      end

      # @label Segmented
      def segmented
        render Strata::US::ButtonGroupComponent.new(segmented: true) do |group|
          group.with_item do
            %(<button class="#{Strata::US::ButtonComponent.css_classes}">Map</button>).html_safe
          end
          group.with_item do
            %(<button class="#{Strata::US::ButtonComponent.css_classes}">Satellite</button>).html_safe
          end
          group.with_item do
            %(<button class="#{Strata::US::ButtonComponent.css_classes}">Hybrid</button>).html_safe
          end
        end
      end
    end
  end
end
