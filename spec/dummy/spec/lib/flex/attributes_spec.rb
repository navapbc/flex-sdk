require "rails_helper"

RSpec.describe Flex::Attributes do
  let(:object) { TestRecord.new }

  describe "memorable_date attribute" do
    it "allows setting a Date" do
      object.date_of_birth = Date.new(2020, 1, 2)
      expect(object.date_of_birth).to eq(Date.new(2020, 1, 2))
      expect(object.date_of_birth.year).to eq(2020)
      expect(object.date_of_birth.month).to eq(1)
      expect(object.date_of_birth.day).to eq(2)
    end

    [
      [ { year: 2020, month: 1, day: 2 }, Date.new(2020, 1, 2), 2020, 1, 2 ],
      [ { year: "2020", month: "1", day: "2" }, Date.new(2020, 1, 2), 2020, 1, 2 ],
      [ { year: "2020", month: "01", day: "02" }, Date.new(2020, 1, 2), 2020, 1, 2 ],
      [ { year: "badyear", month: "badmonth", day: "badday" }, nil, nil, nil, nil ]
    ].each do |input_hash, expected, expected_year, expected_month, expected_day|
      it "allows setting a Hash with year, month, and day [#{input_hash}]" do
        object.date_of_birth = input_hash
        expect(object.date_of_birth).to eq(expected)
        expect(object.date_of_birth_before_type_cast).to eq(input_hash)
        expect(object.date_of_birth&.year).to eq(expected_year)
        expect(object.date_of_birth&.month).to eq(expected_month)
        expect(object.date_of_birth&.day).to eq(expected_day)
      end
    end

    [
      [ "2020-1-2", Date.new(2020, 1, 2), 2020, 1, 2 ],
      [ "2020-01-02", Date.new(2020, 1, 2), 2020, 1, 2 ],
      [ "badyear-badmonth-badday", nil, nil, nil, nil ]
    ].each do |input_string, expected, expected_year, expected_month, expected_day|
      it "allows setting string in format <YEAR>-<MONTH>-<DAY> [#{expected}]" do
        object.date_of_birth = input_string
        expect(object.date_of_birth).to eq(expected)
        expect(object.date_of_birth_before_type_cast).to eq(input_string)
        expect(object.date_of_birth&.year).to eq(expected_year)
        expect(object.date_of_birth&.month).to eq(expected_month)
        expect(object.date_of_birth&.day).to eq(expected_day)
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
    ].each do |input_hash|
      it "validates that date is a valid date #{input_hash}" do
        object.date_of_birth = input_hash
        expect(object.date_of_birth).to be_nil
        expect(object.date_of_birth_before_type_cast).to eq(input_hash)
        expect(object).not_to be_valid
        expect(object.errors.full_messages_for("date_of_birth")).to eq([ "Date of birth is an invalid date" ])
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
      expect(object.test_range).to eq(Date.new(2020, 1, 2)..Date.new(2020, 2, 3))
      expect(object.test_range_start).to eq(Date.new(2020, 1, 2))
      expect(object.test_range_end).to eq(Date.new(2020, 2, 3))
    end

    it "allows setting a hash with start and end strings formatted as mm/dd/yyyy" do
      object.test_range = { start: "01/02/2020", end: "02/03/2020" }
      expect(object.test_range).to eq(Date.new(2020, 1, 2)..Date.new(2020, 2, 3))
      expect(object.test_range_start).to eq(Date.new(2020, 1, 2))
      expect(object.test_range_end).to eq(Date.new(2020, 2, 3))
    end

    it "allows setting to nil" do
      object.test_range = nil
      expect(object.test_range).to be_nil
      expect(object.test_range_start).to be_nil
      expect(object.test_range_end).to be_nil
    end

    context "when start date is after end date" do
      before do
        object.test_range = Date.new(2020, 2, 3)..Date.new(2020, 1, 2)
      end

      it "is invalid with appropriate error message" do
        expect(object).not_to be_valid
        expect(object.test_range).to eq(Date.new(2020, 2, 3)..Date.new(2020, 1, 2))
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
