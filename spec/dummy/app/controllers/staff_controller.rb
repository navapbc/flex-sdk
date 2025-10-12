# frozen_string_literal: true

# Controller for the staff dashboard at /staff.
class StaffController < Strata::StaffController
  def search
  end

  protected

  def case_classes
    [ PassportCase ]
  end

  def header_links
    [ { name: "Search", path: search_path } ] + super
  end
end
