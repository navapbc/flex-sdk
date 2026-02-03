# frozen_string_literal: true

class PaidLeaveApplicationForm < Strata::ApplicationForm
  include Strata::Flows::ApplicationFormValidations
  validate_flow PaidLeaveFlow

  strata_attribute :date_of_birth, :memorable_date

  validates :applicant_name_first, presence: true, on: Flow::NAME
  validates :date_of_birth, presence: true, on: Flow::DATE_OF_BIRTH
  validates :employer_name, presence: true, on: Flow::EMPLOYER_NAME
  validates :leave_type, presence: true, on: Flow::LEAVE_TYPE
end
