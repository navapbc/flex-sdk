require "rails_helper"

RSpec.describe Flex::Attributes::MemorableDateAttribute do
  let(:object) { TestRecord.new }

  it "allows setting a Date" do
    object.date_of_birth = Date.new(2020, 1, 2)
    expect(object.date_of_birth).to eq(Flex::USDate.new(2020, 1, 2))
    expect(object.date_of_birth.year).to eq(2020)
    expect(object.date_of_birth.month).to eq(1)
    expect(object.date_of_birth.day).to eq(2)
  end

  [
    [ { year: 2020, month: 1, day: 2 }, Flex::USDate.new(2020, 1, 2), 2020, 1, 2 ],
    [ { year: "2020", month: "1", day: "2" }, Flex::USDate.new(2020, 1, 2), 2020, 1, 2 ],
    [ { year: "2020", month: "01", day: "02" }, Flex::USDate.new(2020, 1, 2), 2020, 1, 2 ],
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
    [ "2020-1-2", Flex::USDate.new(2020, 1, 2), 2020, 1, 2 ],
    [ "2020-01-02", Flex::USDate.new(2020, 1, 2), 2020, 1, 2 ],
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

  describe "persistence" do
    it "persists and loads memorable date correctly" do
      date = Date.new(2020, 1, 2)
      object.date_of_birth = date
      object.save!

      loaded_record = TestRecord.find(object.id)
      expect(loaded_record.date_of_birth).to eq(date)
      expect(loaded_record.date_of_birth.year).to eq(2020)
      expect(loaded_record.date_of_birth.month).to eq(1)
      expect(loaded_record.date_of_birth.day).to eq(2)
    end
  end
end
