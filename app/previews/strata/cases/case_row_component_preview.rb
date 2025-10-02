# frozen_string_literal: true

module Strata
  class Cases::CaseRowComponentPreview < Lookbook::Preview
    def default
      render(Cases::CaseRowComponent.new(kase: "kase"))
    end
  end
end
