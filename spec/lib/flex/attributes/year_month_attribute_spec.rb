require "rails_helper"
require_relative "value_object_attribute_shared_examples"

RSpec.describe Flex::Attributes::YearMonthAttribute do
  include_examples "value object shared examples", Flex::YearMonth, :activity_reporting_period,
    valid_nested_attributes: FactoryBot.attributes_for(:year_month),
    array_values: [
      FactoryBot.build(:year_month),
      FactoryBot.build(:year_month)
    ],
    invalid_value: FactoryBot.build(:year_month, :invalid)

  it "validates month values are between 1 and 12" do
    object.activity_reporting_period_year = 2025
    object.activity_reporting_period_month = 13
    expect(object).not_to be_valid
    expect(object.errors.full_messages_for(:activity_reporting_period_month)).to include("Activity reporting period month must be in 1..12")

    object.activity_reporting_period_month = 0
    expect(object).not_to be_valid
    expect(object.errors.full_messages_for(:activity_reporting_period_month)).to include("Activity reporting period month must be in 1..12")

    object.activity_reporting_period_month = 6
    expect(object).to be_valid
  end
end
