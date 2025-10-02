# frozen_string_literal: true

module Strata
  class Cases::CaseRowComponent < ViewComponent::Base
    def initialize(kase:, path_func: method(:polymorphic_path))
      @case = kase
      @path_func = path_func
    end
  end
end
