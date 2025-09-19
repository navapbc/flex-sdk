require "rails_helper"
require_relative "value_object_attribute_shared_examples"

RSpec.describe Strata::Attributes::YearMonthAttribute do
  include_examples "value object shared examples", described_class, Strata::YearMonth, :activity_reporting_period,
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
      year_month = Strata::YearMonth.new(year: 2025, month: 2)
      object.activity_reporting_period = year_month
      object.save!

      loaded_object = TestRecord.find(object.id)
      expect(loaded_object.activity_reporting_period.year).to eq(2025)
      expect(loaded_object.activity_reporting_period.month).to eq(2)
    end
  end

  describe "validation" do
    it "validates month values are between 1 and 12" do
      object.activity_reporting_period = { year: 2025, month: 13 }
      expect(object).not_to be_valid
      expect(object.activity_reporting_period.errors.full_messages_for("month")).to include("Month must be in 1..12")

      object.activity_reporting_period = { year: 2025, month: 0 }
      expect(object).not_to be_valid
      expect(object.activity_reporting_period.errors.full_messages_for("month")).to include("Month must be in 1..12")

      object.activity_reporting_period = { year: 2025, month: 2 }
      expect(object).to be_valid
    end

    it "validates year values are present" do
      object.activity_reporting_period = { year: nil, month: 12 }
      expect(object).not_to be_valid
      expect(object.activity_reporting_period.errors.full_messages_for("year")).to include("Year can't be blank")
    end

    it "validates assigning using a properly formatted string" do
      object.activity_reporting_period = "asdf"
      expect(object).not_to be_valid
      expect(object.errors.full_messages_for("activity_reporting_period")).to include("Activity reporting period is an invalid month")
    end

    [ 123, 123.45, Object.new ].each do |invalid_object|
      it "casts #{invalid_object.class} to nil and marks as invalid" do
        object.activity_reporting_period = invalid_object
        expect(object.activity_reporting_period).to be_nil
        expect(object).not_to be_valid
        expect(object.errors.full_messages_for("activity_reporting_period")).to include("Activity reporting period is an invalid month")
      end
    end
  end
end
