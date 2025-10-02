# frozen_string_literal: true

module Strata
  class Cases::CaseRowComponent < ViewComponent::Base
    def initialize(kase:)
      @case = kase
    end
  end
end
