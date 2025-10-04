# frozen_string_literal: true

module Strata
  module Cases
    # Lookbook preview for theIndexComponent.
    class IndexComponentPreview < ViewComponent::Preview
      def default
        case_class = find_valid_case_class
        cases = case_class ? [
          case_class.create,
          case_class.create,
          case_class.create
        ] : []
        render IndexComponent.new(
          cases:,
          model_class: case_class,
          title: "Preview Cases"
        )
      end

      private

      # Find a valid case class that can be used in the preview.
      # We need to find a real case class that can be used in the preview
      # because the IndexComponent uses polymorphic_path to generate the path
      # to the case, so a mock case class won't work.
      def find_valid_case_class
        Case.descendants.find do |descendant|
          begin
            polymorphic_path(descendant)
            true
          rescue NoMethodError, ActionController::UrlGenerationError
            false
          end
        end
      end
    end
  end
end
