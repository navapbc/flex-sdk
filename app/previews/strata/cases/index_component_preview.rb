# frozen_string_literal: true

module Strata
  module Cases
    class IndexComponentPreview < ViewComponent::Preview
      class PreviewCase
        attr_reader :id, :created_at, :model_name

        def initialize(id:)
          @id = id
          @created_at = Time.now
          @model_name = ActiveModel::Name.new(self, nil, "PreviewCase")
        end

        def to_model
          self
        end

        def persisted?
          false
        end
      end

      def default
        cases = [ PreviewCase.new(id: "123"), PreviewCase.new(id: "456") ]
        render IndexComponent.new(
          cases:,
          model_class: PreviewCase,
          title: "Preview Cases",
          path_func: ->(obj, options = {}) do
            if obj.respond_to?(:id) && obj.id
              "/preview_cases/#{obj.id}"
            elsif options[:action]
              "/preview_cases/#{options[:action]}"
            else
              "/preview_cases"
            end
          end
        )
      end
    end
  end
end
