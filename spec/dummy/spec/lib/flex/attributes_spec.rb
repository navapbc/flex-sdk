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

    it "allows setting nested name attributes directly" do
      object.name_first = "John"
      object.name_middle = "Quincy"
      object.name_last = "Adams"
      expect(object.name).to eq(Flex::Name.new("John", "Quincy", "Adams"))
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

    it "allows setting nested address attributes directly" do
      object.address_street_line_1 = "789 Broadway"
      object.address_street_line_2 = "Suite 300"
      object.address_city = "New York"
      object.address_state = "NY"
      object.address_zip_code = "10003"
      expect(object.address).to eq(Flex::Address.new("789 Broadway", "Suite 300", "New York", "NY", "10003"))
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

  describe "money attribute" do
    it "allows setting money as a Money object" do
      money = Flex::Money.new(1250)
      object.weekly_wage = money

      expect(object.weekly_wage).to be_a(Flex::Money)
      expect(object.weekly_wage.cents_amount).to eq(1250)
      expect(object.weekly_wage.dollar_amount).to eq(12.5)
    end

    it "allows setting money as an integer (cents)" do
      object.weekly_wage = 2500

      expect(object.weekly_wage).to be_a(Flex::Money)
      expect(object.weekly_wage.cents_amount).to eq(2500)
      expect(object.weekly_wage.dollar_amount).to eq(25.0)
    end

    it "allows setting money as a hash with dollar_amount" do
      object.weekly_wage = { dollar_amount: 10.50 }

      expect(object.weekly_wage).to be_a(Flex::Money)
      expect(object.weekly_wage.cents_amount).to eq(1050)
      expect(object.weekly_wage.dollar_amount).to eq(10.5)
    end

    describe "edge cases" do
      it "handles nil values" do
        object.weekly_wage = nil
        expect(object.weekly_wage).to be_nil
      end

      it "handles zero values" do
        object.weekly_wage = 0
        expect(object.weekly_wage).to be_a(Flex::Money)
        expect(object.weekly_wage.cents_amount).to eq(0)
        expect(object.weekly_wage.dollar_amount).to eq(0.0)
        expect(object.weekly_wage.to_s).to eq("$0.00")
      end

      it "handles negative values" do
        object.weekly_wage = -500
        expect(object.weekly_wage).to be_a(Flex::Money)
        expect(object.weekly_wage.cents_amount).to eq(-500)
        expect(object.weekly_wage.dollar_amount).to eq(-5.0)
        expect(object.weekly_wage.to_s).to eq("-$5.00")
      end

      it "handles hash with string keys" do
        object.weekly_wage = { "dollar_amount" => "12.34" }
        expect(object.weekly_wage).to be_a(Flex::Money)
        expect(object.weekly_wage.cents_amount).to eq(1234)
        expect(object.weekly_wage.dollar_amount).to eq(12.34)
      end

      it "returns nil for invalid hash" do
        object.weekly_wage = { invalid_key: 100 }
        expect(object.weekly_wage).to be_nil
      end

      it "returns nil for unsupported types" do
        object.weekly_wage = 15.75
        expect(object.weekly_wage).to be_nil
      end
    end
  end

  describe "tax_id attribute" do
    it "allows setting a tax_id as a TaxId object" do
      tax_id = Flex::TaxId.new("123456789")
      object.tax_id = tax_id

      expect(object.tax_id).to be_a(Flex::TaxId)
      expect(object.tax_id.formatted).to eq("123-45-6789")
    end

    it "allows setting a tax_id as a string" do
      object.tax_id = "123456789"

      expect(object.tax_id).to be_a(Flex::TaxId)
      expect(object.tax_id.formatted).to eq("123-45-6789")
    end

    [
      [ "123456789", "123-45-6789" ],
      [ "123-45-6789", "123-45-6789" ],
      [ "123 45 6789", "123-45-6789" ]
    ].each do |input_string, expected|
      it "formats tax_id correctly [#{input_string}]" do
        object.tax_id = input_string
        expect(object.tax_id.formatted).to eq(expected)
      end
    end

    it "preserves invalid values for validation" do
      object.tax_id = "12345"

      expect(object.tax_id).to be_a(Flex::TaxId)
      expect(object.tax_id.formatted).to eq("12345") # Raw value since not 9 digits
      expect(object).not_to be_valid
      expect(object.errors.full_messages_for("tax_id")).to eq([ "Tax ID is not a valid Taxpayer Identification Number (TIN). Use the format (XXX-XX-XXXX)" ])
    end

    describe "TaxId.<=>" do
      it "allows sorting tax ids" do
        tax_ids = [
          Flex::TaxId.new("987654321"),
          Flex::TaxId.new("123456789"),
          Flex::TaxId.new("456789123")
        ]

        sorted_tax_ids = tax_ids.sort
        expect(sorted_tax_ids.map(&:formatted)).to eq([
          "123-45-6789",
          "456-78-9123",
          "987-65-4321"
        ])
      end

      it "compares tax ids numerically" do
        lower = Flex::TaxId.new("123456789")
        higher = Flex::TaxId.new("987654321")

        expect(lower <=> higher).to eq(-1)
        expect(higher <=> lower).to eq(1)
        expect(lower <=> lower).to eq(0)
      end

      it "handles comparison with different formats" do
        tax_id1 = Flex::TaxId.new("123-45-6789")
        tax_id2 = Flex::TaxId.new("123456789")

        expect(tax_id1 <=> tax_id2).to eq(0)
      end

      it "handles comparison with string values" do
        tax_id = Flex::TaxId.new("123-45-6789")
        string_value = "123456789"

        expect(tax_id <=> string_value).to eq(0)
        expect(tax_id <=> "987654321").to eq(-1)
        expect(tax_id <=> "000456789").to eq(1)
      end
    end
  end

  describe "period attribute" do
    it "allows setting period as a Flex::DateRange object" do
      object.period = Flex::DateRange.new(Date.new(2023, 1, 1), Date.new(2023, 12, 31))

      expect(object.period).to eq(Flex::DateRange.new(Date.new(2023, 1, 1), Date.new(2023, 12, 31)))
      expect(object.period_start).to eq(Date.new(2023, 1, 1))
      expect(object.period_end).to eq(Date.new(2023, 12, 31))
      expect(object.period.start).to eq(Date.new(2023, 1, 1))
      expect(object.period.end).to eq(Date.new(2023, 12, 31))
    end

    it "allows setting period as a hash" do
      object.period = { start: Date.new(2023, 6, 1), end: Date.new(2023, 8, 31) }

      expect(object.period).to eq(Flex::DateRange.new(Date.new(2023, 6, 1), Date.new(2023, 8, 31)))
      expect(object.period_start).to eq(Date.new(2023, 6, 1))
      expect(object.period_end).to eq(Date.new(2023, 8, 31))
    end

    it "allows setting period with string keys" do
      object.period = { "start" => Date.new(2023, 3, 1), "end" => Date.new(2023, 5, 31) }

      expect(object.period).to eq(Flex::DateRange.new(Date.new(2023, 3, 1), Date.new(2023, 5, 31)))
      expect(object.period_start).to eq(Date.new(2023, 3, 1))
      expect(object.period_end).to eq(Date.new(2023, 5, 31))
    end

    it "allows setting nested period attributes directly" do
      object.period_start = Date.new(2023, 9, 1)
      object.period_end = Date.new(2023, 11, 30)
      expect(object.period).to eq(Flex::DateRange.new(Date.new(2023, 9, 1), Date.new(2023, 11, 30)))
    end

    it "handles nil values gracefully" do
      object.period = nil
      expect(object.period).to be_nil
      expect(object.period_start).to be_nil
      expect(object.period_end).to be_nil
    end

    it "handles partial periods" do
      object.period = { start: Date.new(2023, 1, 1), end: nil }
      expect(object.period).to eq(Flex::DateRange.new(Date.new(2023, 1, 1), nil))
      expect(object.period_start).to eq(Date.new(2023, 1, 1))
      expect(object.period_end).to be_nil

      object.period = Flex::DateRange.new(nil, Date.new(2023, 12, 31))
      expect(object.period).to eq(Flex::DateRange.new(nil, Date.new(2023, 12, 31)))
      expect(object.period_start).to be_nil
      expect(object.period_end).to eq(Date.new(2023, 12, 31))
    end

    it "validates that start date is before or equal to end date" do
      object.period_start = Date.new(2023, 12, 31)
      object.period_end = Date.new(2023, 1, 1)
      expect(object).not_to be_valid
      expect(object.errors.full_messages_for("period")).to include("Period start date cannot be after end date")
    end

    it "allows start date equal to end date" do
      same_date = Date.new(2023, 6, 15)
      object.period_start = same_date
      object.period_end = same_date
      expect(object).to be_valid
      expect(object.period).to eq(Flex::DateRange.new(same_date, same_date))
    end

    it "allows only one date to be present" do
      object.period_start = Date.new(2023, 1, 1)
      object.period_end = nil
      expect(object).to be_valid

      object.period_start = nil
      object.period_end = Date.new(2023, 12, 31)
      expect(object).to be_valid
    end

    describe "handling invalid dates" do
      it "validates invalid start date format" do
        object.period_start = "not-a-date"
        object.period_end = "2023-12-31"
        expect(object).not_to be_valid
        expect(object.period_start).to be_nil
        expect(object.errors.full_messages_for("period_start")).to include("Period start is an invalid date")
      end

      it "validates invalid end date format" do
        object.period_start = "2023-01-01"
        object.period_end = "invalid-date"
        expect(object).not_to be_valid
        expect(object.period_end).to be_nil
        expect(object.errors.full_messages_for("period_end")).to include("Period end is an invalid date")
      end

      it "validates both dates when both are invalid" do
        object.period = { start: "bad-start", end: "bad-end" }
        expect(object).not_to be_valid
        expect(object.period_start).to be_nil
        expect(object.period_end).to be_nil
        expect(object.errors.full_messages_for("period_start")).to include("Period start is an invalid date")
        expect(object.errors.full_messages_for("period_end")).to include("Period end is an invalid date")
      end

      it "handles invalid date components" do
        object.period_start = "13/45/2023"
        object.period_end = "12/31/2023"
        expect(object).not_to be_valid
        expect(object.period_start).to be_nil
        expect(object.errors.full_messages_for("period_start")).to include("Period start is an invalid date")
      end

      it "handles leap year edge cases" do
        object.period_start = "02/29/2023"
        object.period_end = "02/29/2024"
        expect(object).not_to be_valid
        expect(object.period_start).to be_nil
        expect(object.period_end).to be_a(Date)  # This date is valid since 2024 is a leap year
        expect(object.errors.full_messages_for("period_start")).to include("Period start is an invalid date")
      end
    end

    [
      [ "allows setting period as a Ruby Range of dates", Date.new(2023, 1, 1), Date.new(2023, 12, 31), Flex::DateRange.new(Date.new(2023, 1, 1), Date.new(2023, 12, 31)) ],
      [ "allows setting period as a Ruby Range of dates with same start and end", Date.new(2023, 6, 15), Date.new(2023, 6, 15), Flex::DateRange.new(Date.new(2023, 6, 15), Date.new(2023, 6, 15)) ],
      [ "allows setting period as a Ruby Range of dates with nil start", nil, Date.new(2023, 12, 31), Flex::DateRange.new(nil, Date.new(2023, 12, 31)) ],
      [ "allows setting period as a Ruby Range of dates with nil end", Date.new(2023, 1, 1), nil, Flex::DateRange.new(Date.new(2023, 1, 1), nil) ],
      [ "sets nil if setting a nil..nil Range", nil, nil, nil ]
    ].each do |description, start_date, end_date, expected|
      it description do
        object.period = start_date..end_date

        expect(object.period).to eq(expected)
        expect(object.period_start).to eq(start_date)
        expect(object.period_end).to eq(end_date)
      end
    end

    it "ignores Range objects that don't contain dates" do
      object.period = 1..10
      expect(object.period).to be_nil
      expect(object.period_start).to be_nil
      expect(object.period_end).to be_nil
    end
  end

  describe "year_quarter attribute" do
    it "allows setting year_quarter as a value object" do
      year_quarter = Flex::YearQuarter.new(2023, 2)
      object.reporting_period = year_quarter

      expect(object.reporting_period).to eq(Flex::YearQuarter.new(2023, 2))
      expect(object.reporting_period_year).to eq(2023)
      expect(object.reporting_period_quarter).to eq(2)
    end

    it "allows setting year_quarter as a hash" do
      object.reporting_period = { year: 2024, quarter: 3 }

      expect(object.reporting_period).to eq(Flex::YearQuarter.new(2024, 3))
      expect(object.reporting_period_year).to eq(2024)
      expect(object.reporting_period_quarter).to eq(3)
    end

    it "allows setting nested year_quarter attributes directly" do
      object.reporting_period_year = 2025
      object.reporting_period_quarter = 1
      expect(object.reporting_period).to eq(Flex::YearQuarter.new(2025, 1))
    end

    it "validates quarter values are between 1 and 4" do
      object.reporting_period_quarter = 5
      expect(object).not_to be_valid
      expect(object.errors.full_messages_for("reporting_period_quarter")).to include("Reporting period quarter is not included in the list")

      object.reporting_period_quarter = 0
      expect(object).not_to be_valid
      expect(object.errors.full_messages_for("reporting_period_quarter")).to include("Reporting period quarter is not included in the list")

      object.reporting_period_quarter = 2
      expect(object).to be_valid
    end

    describe "YearQuarter.<=>" do
      it "allows sorting year quarters" do
        year_quarters = [
          Flex::YearQuarter.new(2024, 3),
          Flex::YearQuarter.new(2023, 1),
          Flex::YearQuarter.new(2024, 1)
        ]

        sorted_year_quarters = year_quarters.sort
        expect(sorted_year_quarters).to eq([
          Flex::YearQuarter.new(2023, 1),
          Flex::YearQuarter.new(2024, 1),
          Flex::YearQuarter.new(2024, 3)
        ])
      end

      it "compares year quarters by year first, then quarter" do
        earlier = Flex::YearQuarter.new(2023, 4)
        later = Flex::YearQuarter.new(2024, 1)

        expect(earlier <=> later).to eq(-1)
        expect(later <=> earlier).to eq(1)
        expect(earlier <=> earlier).to eq(0)
      end

      it "compares quarters within the same year" do
        q1 = Flex::YearQuarter.new(2024, 1)
        q3 = Flex::YearQuarter.new(2024, 3)

        expect(q1 <=> q3).to eq(-1)
        expect(q3 <=> q1).to eq(1)
      end
    end
  end

  describe "persisting and loading from database" do
    let(:record) { TestRecord.new }

    it "persists and loads name object correctly" do
      name = Flex::Name.new("John", "Middle", "Doe")
      record.name = name
      record.save!

      loaded_record = TestRecord.find(record.id)
      expect(loaded_record.name).to be_a(Flex::Name)
      expect(loaded_record.name).to eq(name)
      expect(loaded_record.name_first).to eq("John")
      expect(loaded_record.name_middle).to eq("Middle")
      expect(loaded_record.name_last).to eq("Doe")
    end

    it "persists and loads address object correctly" do
      address = Flex::Address.new("123 Main St", "Apt 4B", "Boston", "MA", "02108")
      record.address = address
      record.save!

      loaded_record = TestRecord.find(record.id)
      expect(loaded_record.address).to be_a(Flex::Address)
      expect(loaded_record.address).to eq(address)
      expect(loaded_record.address_street_line_1).to eq("123 Main St")
      expect(loaded_record.address_street_line_2).to eq("Apt 4B")
      expect(loaded_record.address_city).to eq("Boston")
      expect(loaded_record.address_state).to eq("MA")
      expect(loaded_record.address_zip_code).to eq("02108")
    end

    it "persists and loads tax_id object correctly" do
      tax_id = Flex::TaxId.new("123-45-6789")
      record.tax_id = tax_id
      record.save!

      loaded_record = TestRecord.find(record.id)
      expect(loaded_record.tax_id).to be_a(Flex::TaxId)
      expect(loaded_record.tax_id).to eq(tax_id)
      expect(loaded_record.tax_id.formatted).to eq("123-45-6789")
    end

    it "persists and loads money object correctly" do
      money = Flex::Money.new(1250)
      record.weekly_wage = money
      record.save!

      loaded_record = TestRecord.find(record.id)
      expect(loaded_record.weekly_wage).to be_a(Flex::Money)
      expect(loaded_record.weekly_wage).to eq(money)
      expect(loaded_record.weekly_wage.cents_amount).to eq(1250)
      expect(loaded_record.weekly_wage.dollar_amount).to eq(12.5)
    end

    it "persists and loads memorable date correctly" do
      date = Date.new(2020, 1, 2)
      record.date_of_birth = date
      record.save!

      loaded_record = TestRecord.find(record.id)
      expect(loaded_record.date_of_birth).to eq(date)
      expect(loaded_record.date_of_birth.year).to eq(2020)
      expect(loaded_record.date_of_birth.month).to eq(1)
      expect(loaded_record.date_of_birth.day).to eq(2)
    end

    it "persists and loads period object correctly" do
      record.period = Date.new(2023, 1, 1)..Date.new(2023, 12, 31)
      record.save!

      loaded_record = TestRecord.find(record.id)
      expect(loaded_record.period).to eq(Flex::DateRange.new(Date.new(2023, 1, 1), Date.new(2023, 12, 31)))
      expect(loaded_record.period_start).to eq(Date.new(2023, 1, 1))
      expect(loaded_record.period_end).to eq(Date.new(2023, 12, 31))
      expect(loaded_record.period.start).to eq(Date.new(2023, 1, 1))
      expect(loaded_record.period.end).to eq(Date.new(2023, 12, 31))

      record.period_start = "01/05/2023"
      record.period_end = "06/12/2023"
      record.save!

      loaded_record = TestRecord.find(record.id)
      expect(loaded_record.period).to eq(Flex::DateRange.new(Date.new(2023, 1, 5), Date.new(2023, 6, 12)))
      expect(loaded_record.period_start).to eq(Date.new(2023, 1, 5))
      expect(loaded_record.period_end).to eq(Date.new(2023, 6, 12))
      expect(loaded_record.period.start).to eq(Date.new(2023, 1, 5))
      expect(loaded_record.period.end).to eq(Date.new(2023, 6, 12))
    end

    it "preserves all attributes when saving and loading multiple value objects" do
      record.name = Flex::Name.new("Jane", "Marie", "Smith")
      record.address = Flex::Address.new("456 Oak St", "Unit 7", "Chicago", "IL", "60601")
      record.tax_id = Flex::TaxId.new("987-65-4321")
      record.weekly_wage = Flex::Money.new(5000)
      record.date_of_birth = Date.new(1990, 3, 15)
      record.period = Flex::DateRange.new(Date.new(2023, 1, 1), Date.new(2023, 12, 31))
      record.save!

      loaded_record = TestRecord.find(record.id)

      # Verify name
      expect(loaded_record.name).to eq(Flex::Name.new("Jane", "Marie", "Smith"))
      expect(loaded_record.name_first).to eq("Jane")
      expect(loaded_record.name_middle).to eq("Marie")
      expect(loaded_record.name_last).to eq("Smith")

      # Verify address
      expect(loaded_record.address).to eq(Flex::Address.new("456 Oak St", "Unit 7", "Chicago", "IL", "60601"))
      expect(loaded_record.address_street_line_1).to eq("456 Oak St")
      expect(loaded_record.address_street_line_2).to eq("Unit 7")
      expect(loaded_record.address_city).to eq("Chicago")
      expect(loaded_record.address_state).to eq("IL")
      expect(loaded_record.address_zip_code).to eq("60601")

      # Verify tax_id
      expect(loaded_record.tax_id).to eq(Flex::TaxId.new("987-65-4321"))
      expect(loaded_record.tax_id.formatted).to eq("987-65-4321")

      # Verify money
      expect(loaded_record.weekly_wage).to eq(Flex::Money.new(5000))
      expect(loaded_record.weekly_wage.cents_amount).to eq(5000)
      expect(loaded_record.weekly_wage.dollar_amount).to eq(50.0)

      # Verify date_of_birth
      expect(loaded_record.date_of_birth).to eq(Date.new(1990, 3, 15))

      # Verify date_range
      expect(loaded_record.period).to eq(Flex::DateRange.new(Date.new(2023, 1, 1), Date.new(2023, 12, 31)))
      expect(loaded_record.period_start).to eq(Date.new(2023, 1, 1))
      expect(loaded_record.period_end).to eq(Date.new(2023, 12, 31))
    end

    it "persists and loads year_quarter object correctly" do
      year_quarter = Flex::YearQuarter.new(2023, 4)
      record.reporting_period = year_quarter
      record.save!

      loaded_record = TestRecord.find(record.id)
      expect(loaded_record.reporting_period).to be_a(Flex::YearQuarter)
      expect(loaded_record.reporting_period).to eq(year_quarter)
      expect(loaded_record.reporting_period_year).to eq(2023)
      expect(loaded_record.reporting_period_quarter).to eq(4)
    end
  end

  describe "document attribute" do
    let(:test_record) { TestRecord.new }
    let(:uploaded_file) do
      fixture_file_upload(Rails.root.join("spec", "fixtures", "test_document.txt"), "text/plain")
    end
    let(:second_file) do
      fixture_file_upload(Rails.root.join("spec", "fixtures", "test_document.txt"), "text/plain")
    end

    it "returns a DocumentCollection when accessed" do
      expect(test_record.attachments).to be_a(Flex::DocumentCollection)
      expect(test_record.attachments).to be_empty
    end

    it "handles single file upload assignment" do
      test_record.attachments = uploaded_file
      expect(test_record.attachments_files).to be_attached
      expect(test_record.attachments.count).to eq(1)
    end

    it "handles multiple file uploads" do
      files = [ uploaded_file, second_file ]
      test_record.attachments = files
      expect(test_record.attachments.count).to eq(2)
    end

    it "handles empty array assignment" do
      test_record.attachments = []
      expect(test_record.attachments).to be_empty
      expect(test_record.attachments.count).to eq(0)
    end

    it "handles nil assignment" do
      test_record.attachments = nil
      expect(test_record.attachments).to be_empty
      expect(test_record.attachments.count).to eq(0)
    end

    it "provides access to filenames" do
      test_record.attachments = uploaded_file
      expect(test_record.attachments.filenames).to include("test_document.txt")
    end

    it "calculates total size" do
      test_record.attachments = uploaded_file
      expect(test_record.attachments.total_size).to be > 0
    end

    it "supports enumeration" do
      test_record.attachments = uploaded_file
      expect(test_record.attachments).to all(respond_to(:filename))
    end

    it "supports present? and empty? methods" do
      expect(test_record.attachments).to be_empty
      expect(test_record.attachments).not_to be_present

      test_record.attachments = uploaded_file
      expect(test_record.attachments).not_to be_empty
      expect(test_record.attachments).to be_present
    end

    describe "persistence" do
      it "persists and loads document attachments correctly" do
        test_record.attachments = uploaded_file
        test_record.save!

        loaded_record = TestRecord.find(test_record.id)
        expect(loaded_record.attachments).to be_a(Flex::DocumentCollection)
        expect(loaded_record.attachments.count).to eq(1)
        expect(loaded_record.attachments.filenames).to include("test_document.txt")
      end

      it "persists multiple attachments correctly" do
        files = [ uploaded_file, second_file ]
        test_record.attachments = files
        test_record.save!

        loaded_record = TestRecord.find(test_record.id)
        expect(loaded_record.attachments.count).to eq(2)
        expect(loaded_record.attachments.filenames.all? { |name| name == "test_document.txt" }).to be true
      end

      it "handles attachment removal" do
        test_record.attachments = uploaded_file
        test_record.save!
        expect(test_record.attachments.count).to eq(1)

        test_record.attachments_files.purge
        test_record.reload
        expect(test_record.attachments).to be_empty
      end
    end
  end
end
