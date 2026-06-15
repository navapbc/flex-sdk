# frozen_string_literal: true

class LeaveRequestApplicationForm < Strata::ApplicationForm
  include Strata::Attributes

  strata_attribute :date_of_birth, :memorable_date

  attribute :first_name, :string
  attribute :last_name, :string
  attribute :street_address, :string
  attribute :zip_code, :string
end
