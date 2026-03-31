# frozen_string_literal: true

class TestApplicationForm < Strata::ApplicationForm
  attribute :test_string, :string

  strata_attribute :applicant_name, :name
  strata_attribute :mailing_address, :address
  strata_attribute :date_of_birth, :memorable_date
  strata_attribute :salary, :money
  strata_attribute :ssn, :tax_id
  strata_attribute :hire_date, :us_date

  enum :leave_type, medical: 0, family: 1, military: 2

  has_one_attached :resume
end
