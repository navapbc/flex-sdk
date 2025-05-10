require "rails_helper"

RSpec.describe Flex::Attributes do
  describe "memorable_date attribute" do
    before do
      test_model = Class.new do
        include ActiveModel::Attributes
        include ActiveModel::Validations
        include Flex::Attributes

        flex_attribute :test_date, :memorable_date
      end
      stub_const "TestModel", test_model
    end

    let(:object) { TestModel.new }


    it "allows setting a Date" do
      object.test_date = Date.new(2020, 1, 2)
      expect(object.test_date).to eq("2020-01-02")
      expect(object.test_date.year).to eq("2020")
      expect(object.test_date.month).to eq("1")
      expect(object.test_date.day).to eq("2")
    end

    [
      [ { year: 2020, month: 1, day: 2 }, "2020-01-02", "2020", "1", "2" ],
      [ { year: "2020", month: "1", day: "2" }, "2020-01-02", "2020", "1", "2" ],
      [ { year: "2020", month: "01", day: "02" }, "2020-01-02", "2020", "01", "02" ],
      [ { year: "badyear", month: "badmonth", day: "badday" }, "badyear-badmonth-badday", "badyear", "badmonth", "badday" ]
    ].each do |input_hash, expected, expected_year, expected_month, expected_day|
      it "allows setting a Hash with year, month, and day [#{expected}]" do
        object.test_date = input_hash
        expect(object.test_date).to eq(expected)
        expect(object.test_date.year).to eq(expected_year)
        expect(object.test_date.month).to eq(expected_month)
        expect(object.test_date.day).to eq(expected_day)
      end
    end

    [
      [ "2020-1-2", "2020-01-02", "2020", "1", "2" ],
      [ "2020-01-02", "2020-01-02", "2020", "01", "02" ],
      [ "badyear-badmonth-badday", "badyear-badmonth-badday", "badyear", "badmonth", "badday" ]
    ].each do |input_string, expected, expected_year, expected_month, expected_day|
      it "allows setting string in format <YEAR>-<MONTH>-<DAY> [#{expected}]" do
        object.test_date = input_string
        expect(object.test_date).to eq(expected)
        expect(object.test_date.year).to eq(expected_year)
        expect(object.test_date.month).to eq(expected_month)
        expect(object.test_date.day).to eq(expected_day)
      end
    end

    [
      { year: 2020, month: 1, day: -1 },
      { year: 2020, month: 1, day: 0 },
      { year: 2020, month: 1, day: 32 },
      { year: 2020, month: -1, day: 1 },
      { year: 2020, month: 0, day: 1 },
      { year: 2020, month: 13, day: 1 },
      { year: 2020, month: 2, day: 30 }
    ].each do |date|
      it "validates that date is a valid date" do
        object.test_date = date
        expect(object.test_date).to eq("%04d-%02d-%02d" % [ date[:year], date[:month], date[:day] ])
        expect(object).not_to be_valid
        expect(object.errors["test_date"]).to include("is not a valid date")
      end
    end
  end

  describe "date_range attribute" do
    before do
      test_model = Class.new(ApplicationRecord) do
        self.table_name = "test_records"
        include Flex::Attributes

        flex_attribute :test_range, :date_range
      end
      stub_const "TestModelWithRange", test_model
    end

    let(:object) { TestModelWithRange.new }

    it "allows setting a Range of Date objects" do
      object.test_range = Date.new(2020, 1, 2)..Date.new(2020, 2, 3)
      expect(object.test_range_start).to eq(Date.new(2020, 1, 2))
      expect(object.test_range_end).to eq(Date.new(2020, 2, 3))
      expect(object.test_range).to eq(Date.new(2020, 1, 2)..Date.new(2020, 2, 3))
    end

    it "allows setting to nil" do
      object.test_range = nil
      expect(object.test_range).to be_nil
      expect(object.test_range_start).to be_nil
      expect(object.test_range_end).to be_nil
    end

    context "when start date is after end date" do
      before do
        object.test_range_start = Date.new(2020, 2, 3)
        object.test_range_end = Date.new(2020, 1, 2)
      end

      it "is invalid with appropriate error message" do
        expect(object).not_to be_valid
        expect(object.errors[:test_range].first).to eq("Start date must be less than or equal to end date")
      end
    end

    context "with only one date set to nil" do
      it "is invalid when only start date is nil" do
        object.test_range_start = nil
        object.test_range_end = Date.new(2020, 1, 2)

        expect(object).not_to be_valid
        expect(object.errors[:test_range].first).to eq("Both start and end dates must be present or both must be nil")
      end

      it "is invalid when only end date is nil" do
        object.test_range_start = Date.new(2020, 1, 2)
        object.test_range_end = nil

        expect(object).not_to be_valid
        expect(object.errors[:test_range].first).to eq("Both start and end dates must be present or both must be nil")
      end
    end
  end
end
