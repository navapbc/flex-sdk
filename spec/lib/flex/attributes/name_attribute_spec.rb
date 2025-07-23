require "rails_helper"
require_relative "value_object_attribute_shared_examples"

RSpec.describe Flex::Attributes::NameAttribute do
  include_examples "value object shared examples", Flex::Name, :name,
    valid_nested_attributes: FactoryBot.attributes_for(:name, :base, :with_middle),
    nested_attributes_without_normalization: {
      first: "jean-luc",
      middle: "von",
      last: "O'REILLY"
    },
    array_values: [
      FactoryBot.build(:name, :base),
      FactoryBot.build(:name, :base, :with_middle)
    ]
end
