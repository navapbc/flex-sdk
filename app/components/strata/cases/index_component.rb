# frozen_string_literal: true

module Strata
  module Cases
    class IndexComponent < ViewComponent::Base
      def initialize(
        cases:,
        model_class:,
        case_row_component_class: CaseRowComponent,
        path_func: method(:polymorphic_path),
        title: "Cases"
      )
        @cases = cases
        @model_class = model_class
        @title = title
        @case_row_component_class = case_row_component_class
        @path_func = path_func
      end
    end
  end
end
