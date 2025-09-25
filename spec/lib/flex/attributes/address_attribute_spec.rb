require "rails_helper"
require_relative "value_object_attribute_shared_examples"

RSpec.describe Flex::Attributes::AddressAttribute do
  include_examples "value object shared examples", described_class, Strata::Address, :address,
    valid_nested_attributes: FactoryBot.attributes_for(:address, :base, :with_street_line_2),
    nested_attributes_without_normalization: {
      street_line_1: "789 BROADWAY",
      street_line_2: "",
      city: "new york",
      state: "NY",
      zip_code: "10003"
    },
    array_values: [
      FactoryBot.build(:address, :base),
      FactoryBot.build(:address, :base, :with_street_line_2)
    ],
    invalid_value: FactoryBot.build(:address, :invalid)
end
