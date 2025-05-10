class TestRecord < ApplicationRecord
  include Flex::Attributes
  
  flex_attribute :period, :date_range
end
