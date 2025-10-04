# frozen_string_literal: true

module Strata
  module Cases
    # IndexComponent renders a table of cases with headers and rows.
    # It provides a reusable interface for displaying lists of cases
    # with customizable row components and URL path generation.
    #
    # @example Basic usage
    #   <%= render IndexComponent.new(cases: @cases, model_class: MyCase) %>
    #
    class IndexComponent < ViewComponent::Base
      def initialize(
        cases:,
        model_class:,
        title: "Cases",
        case_row_component_class: CaseRowComponent
      )
        @cases = cases
        @model_class = model_class
        @title = title
        @case_row_component_class = case_row_component_class
      end
    end
  end
end
