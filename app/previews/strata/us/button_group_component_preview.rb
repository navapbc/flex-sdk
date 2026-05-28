# frozen_string_literal: true

module Strata
  module US
    # ButtonGroupComponentPreview provides preview examples for the Strata::US::ButtonGroupComponent.
    class ButtonGroupComponentPreview < Lookbook::Preview
      layout "strata/component_preview"

      # @label Default
      # Renders via the sibling `default.html.erb` template — nested `render` calls don't work inside slot blocks in a Lookbook preview method.
      def default; end

      # @label Segmented
      # Renders via the sibling `segmented.html.erb` template — nested `render` calls don't work inside slot blocks in a Lookbook preview method.
      def segmented; end
    end
  end
end
