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

  describe "name attribute" do
    it "allows setting name as a value object" do
      name = Flex::Name.new("Jane", "Marie", "Doe")
      object.name = name

      expect(object.name).to eq(Flex::Name.new("Jane", "Marie", "Doe"))
      expect(object.name_first).to eq("Jane")
      expect(object.name_middle).to eq("Marie")
      expect(object.name_last).to eq("Doe")
    end

    it "allows setting name as a hash" do
      object.name = { first: "Alice", middle: "Beth", last: "Johnson" }

      expect(object.name).to eq(Flex::Name.new("Alice", "Beth", "Johnson"))
      expect(object.name_first).to eq("Alice")
      expect(object.name_middle).to eq("Beth")
      expect(object.name_last).to eq("Johnson")
    end

    it "preserves values exactly as entered without normalization" do
      object.name = { first: "jean-luc", middle: "von", last: "O'REILLY" }

      expect(object.name).to eq(Flex::Name.new("jean-luc", "von", "O'REILLY"))
      expect(object.name_first).to eq("jean-luc")
      expect(object.name_middle).to eq("von")
      expect(object.name_last).to eq("O'REILLY")
    end
  end

  describe "address attribute" do
    it "allows setting address as a value object" do
      address = Flex::Address.new("123 Main St", "Apt 4B", "Boston", "MA", "02108")
      object.address = address

      expect(object.address).to eq(Flex::Address.new("123 Main St", "Apt 4B", "Boston", "MA", "02108"))
      expect(object.address_street_line_1).to eq("123 Main St")
      expect(object.address_street_line_2).to eq("Apt 4B")
      expect(object.address_city).to eq("Boston")
      expect(object.address_state).to eq("MA")
      expect(object.address_zip_code).to eq("02108")
    end

    it "allows setting address as a hash" do
      object.address = { 
        street_line_1: "456 Oak Ave",
        street_line_2: "Unit 7C",
        city: "San Francisco",
        state: "CA",
        zip_code: "94107"
      }

      expect(object.address).to eq(Flex::Address.new("456 Oak Ave", "Unit 7C", "San Francisco", "CA", "94107"))
      expect(object.address_street_line_1).to eq("456 Oak Ave")
      expect(object.address_street_line_2).to eq("Unit 7C")
      expect(object.address_city).to eq("San Francisco")
      expect(object.address_state).to eq("CA")
      expect(object.address_zip_code).to eq("94107")
    end

    it "preserves values exactly as entered without normalization" do
      object.address = { 
        street_line_1: "789 BROADWAY",
        street_line_2: "",
        city: "new york",
        state: "NY",
        zip_code: "10003"
      }

      expect(object.address).to eq(Flex::Address.new("789 BROADWAY", "", "new york", "NY", "10003"))
      expect(object.address_street_line_1).to eq("789 BROADWAY")
      expect(object.address_street_line_2).to eq("")
      expect(object.address_city).to eq("new york")
      expect(object.address_state).to eq("NY")
      expect(object.address_zip_code).to eq("10003")
    end
  end
end
