class TestRecord < ApplicationRecord
  include Strata::Attributes

  flex_attribute :address, :address
  flex_attribute :date_of_birth, :memorable_date
  flex_attribute :weekly_wage, :money
  flex_attribute :name, :name
  flex_attribute :adopted_on, :us_date
  flex_attribute :period, :us_date, range: true
  flex_attribute :tax_id, :tax_id
  flex_attribute :reporting_period, :year_quarter
  flex_attribute :base_period, :year_quarter, range: true
  flex_attribute :activity_reporting_period, :year_month

  # Array types
  flex_attribute :addresses, :address, array: true
  flex_attribute :leave_periods, [ :us_date, range: true ], array: true
  flex_attribute :names, :name, array: true
  flex_attribute :reporting_periods, :year_quarter, array: true
  flex_attribute :activity_reporting_periods, :year_month, array: true
end
