# frozen_string_literal: true

module Strata
  module Cases
    class CaseRowComponentPreview < ViewComponent::Preview

      class PreviewCase
        def id
          "123"
        end
  
        def created_at
          Time.now
        end
  
        def model_name
          ActiveModel::Name.new(self, nil, "PreviewCase")
        end

        def to_model
          self
        end

        def persisted?
          false
        end
      end

      def default
        render CaseRowComponent.new(
          kase: PreviewCase.new,
          path_func: ->(obj) { "/preview_cases/#{obj.id}" }
        )
      end
    end
  end
end
