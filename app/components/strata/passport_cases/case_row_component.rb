# frozen_string_literal: true

module Strata
  class PassportCases::CaseRowComponent < ViewComponent::Base
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
