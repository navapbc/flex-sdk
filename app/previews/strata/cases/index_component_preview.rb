# frozen_string_literal: true

module Strata
  module Cases
    # Lookbook preview for theIndexComponent.
    class IndexComponentPreview < ViewComponent::Preview
      # PreviewCase is a mock case object used for component previews.
      # It implements the minimal interface required by the IndexComponent
      # to render preview data without requiring a full database setup.
      class PreviewCase
        attr_reader :id, :created_at, :model_name, :business_process_current_step

        def initialize(id:)
          @id = id
          @created_at = Time.now
          @model_name = ActiveModel::Name.new(self, nil, "PreviewCase")
          @business_process_current_step = "Review case"
        end

        def business_process_instance
          BusinessProcessInstance.new(self, business_process_current_step)
        end

        def tasks
          [ Task.new(due_on: Date.today + 1.day) ]
        end

        def to_model
          self
        end

        def persisted?
          false
        end
      end

      def default
        cases = [ PreviewCase.new(id: "123"), PreviewCase.new(id: "456"), PreviewCase.new(id: "789") ]
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
