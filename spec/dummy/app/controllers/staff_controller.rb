# frozen_string_literal: true

# Controller for the staff dashboard at /staff.
class StaffController < Strata::StaffController
  protected

  def case_classes
    [ PassportCase ]
  end
end
