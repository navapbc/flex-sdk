class TestRecord < ApplicationRecord
  include Flex::Attributes

  flex_attribute :address, :address
  flex_attribute :date_of_birth, :memorable_date
  flex_attribute :weekly_wage, :money
  flex_attribute :name, :name
  flex_attribute :period, :date_range
  flex_attribute :tax_id, :tax_id
  flex_attribute :reporting_period, :year_quarter
  flex_attribute :base_period, :year_quarter_range

  # Array types
  flex_attribute :addresses, :address, array: true
  flex_attribute :leave_periods, :date_range, array: true
  flex_attribute :names, :name, array: true
  flex_attribute :reporting_periods, :year_quarter, array: true
end
