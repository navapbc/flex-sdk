# frozen_string_literal: true

module Strata
  module PassportCases
    # Custom CaseRowComponent for rendering a single row in a passport cases table.
    # It displays passport case information including the case ID.
    class CaseRowComponent < ViewComponent::Base
      def initialize(kase:, path_func:)
        @case = kase
        @path_func = path_func
      end

      def self.headers
        [
          "Passport Case ID"
        ]
      end
    end
  end
end
