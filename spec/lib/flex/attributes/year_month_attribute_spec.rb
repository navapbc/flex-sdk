require "rails_helper"
require_relative "value_object_attribute_shared_examples"

RSpec.describe Flex::Attributes::YearMonthAttribute do
  include_examples "value object shared examples", described_class, Flex::YearMonth, :activity_reporting_period,
    valid_nested_attributes: FactoryBot.attributes_for(:year_month),
    array_values: [
      FactoryBot.build(:year_month),
      FactoryBot.build(:year_month)
    ],
    invalid_value: FactoryBot.build(:year_month, :invalid)

  describe "string assignment" do
    it "accepts string values in 'YYYY-MM' format" do
      object.activity_reporting_period = "2025-02"
      expect(object.activity_reporting_period.year).to eq(2025)
      expect(object.activity_reporting_period.month).to eq(2)
    end

    it "accepts string values in 'YYYY-MM' format without leading zeros" do
      object.activity_reporting_period = "2025-6"
      expect(object.activity_reporting_period.year).to eq(2025)
      expect(object.activity_reporting_period.month).to eq(6)
    end

    it "returns nil for invalid string formats" do
      object.activity_reporting_period = "invalid"
      expect(object.activity_reporting_period).to be_nil
    end

    it "returns nil for strings without dash separator" do
      object.activity_reporting_period = "202502"
      expect(object.activity_reporting_period).to be_nil
    end

    it "serializes to string format with leading zeros" do
      year_month = Flex::YearMonth.new(year: 2025, month: 2)
      object.activity_reporting_period = year_month
      object.save!

      loaded_object = TestRecord.find(object.id)
      expect(loaded_object.activity_reporting_period.year).to eq(2025)
      expect(loaded_object.activity_reporting_period.month).to eq(2)
    end
  end
end
