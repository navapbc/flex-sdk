class TestRecord < ApplicationRecord
  include Flex::Attributes

  flex_attribute :address, :address
  flex_attribute :date_of_birth, :memorable_date
  flex_attribute :weekly_wage, :money
  flex_attribute :name, :name
  flex_attribute :period, :date_range
  flex_attribute :tax_id, :tax_id
  flex_attribute :reporting_period, :year_quarter

  # Array types
  flex_attribute :addresses, [:address]
  flex_attribute :leave_periods, [:date_range]
  flex_attribute :names, [:name]
  flex_attribute :reporting_periods, [:year_quarter]
end
