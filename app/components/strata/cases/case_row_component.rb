# frozen_string_literal: true

module Strata
  module Cases
    # CaseRowComponent renders a single row in a cases table.
    # It displays case information including ID, creation date, and action links.
    #
    # This component is used by IndexComponent to render individual case rows.
    #
    # @example Basic usage
    #   <%= render CaseRowComponent.new(kase: @case) %>
    #
    class CaseRowComponent < ViewComponent::Base
      def initialize(kase:, path_func: method(:polymorphic_path))
        @case = kase
        @path_func = path_func
      end

      def self.headers
        [
          t(".case_id"),
          t(".created"),
          t(".action")
        ]
      end
    end
  end
end
