# frozen_string_literal: true

module Strata
  module Cases
    class IndexComponent < ViewComponent::Base
      def initialize(
        case_row_component_class: CaseRowComponent,
        cases:,
        model_class:,
        path_func: method(:polymorphic_path),
        title:
      )
        @cases = cases
        @case_row_component_class = case_row_component_class
        @model_class = model_class
        @path_func = path_func
        @title = title
      end
    end
  end
end
