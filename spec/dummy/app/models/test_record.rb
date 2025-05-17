class TestRecord < ApplicationRecord
  include Flex::Attributes

  flex_attribute :date_of_birth, :memorable_date
  flex_attribute :name, :name
end
