class TestRecord < ApplicationRecord
  include Flex::Attributes

  flex_attribute :address, :address
  flex_attribute :date_of_birth, :memorable_date
  flex_attribute :date_range, :date_range
  flex_attribute :name, :name
  flex_attribute :tax_id, :tax_id
end
