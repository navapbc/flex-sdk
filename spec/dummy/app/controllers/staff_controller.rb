# Controller for the staff dashboard at /staff.
class StaffController < Flex::StaffController
  protected

  def case_classes
    [ PassportCase ]
  end
end
