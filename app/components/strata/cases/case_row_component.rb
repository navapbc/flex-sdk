# frozen_string_literal: true

module Strata
  module Cases
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
