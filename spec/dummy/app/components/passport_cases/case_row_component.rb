# frozen_string_literal: true

module PassportCases
  # Custom CaseRowComponent for rendering a single row in a passport cases table.
  # It displays passport case information including the case ID.
  class CaseRowComponent < Strata::Cases::CaseRowComponent
    def self.columns
      [ :passport_id ] + super
    end

    protected

    def passport_id
      @case.passport_id.to_s[-9, 9]
    end
  end
end
