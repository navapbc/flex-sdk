require "rails_helper"

RSpec.describe Flex::Attributes do
  let(:object) { TestRecord.new }

  # rubocop:disable RSpec/MultipleMemoizedHelpers
  describe "address attribute" do
    let(:street_line_1) { "456 Oak Ave" } # rubocop:disable RSpec/IndexedLet
    let(:street_line_2) { "Unit 7C" } # rubocop:disable RSpec/IndexedLet
    let(:city) { "San Francisco" }
    let(:state) { "CA" }
    let(:zip_code) { "94107" }

    it "allows setting address as a value object" do
      address = Flex::Address.new(street_line_1:, street_line_2:, city:, state:, zip_code:)
      object.address = address

      expect(object.address).to eq(Flex::Address.new(street_line_1:, street_line_2:, city:, state:, zip_code:))
      expect(object.address_street_line_1).to eq(street_line_1)
      expect(object.address_street_line_2).to eq(street_line_2)
      expect(object.address_city).to eq(city)
      expect(object.address_state).to eq(state)
      expect(object.address_zip_code).to eq(zip_code)
    end

    it "allows setting address as a hash" do
      object.address = {
        street_line_1:,
        street_line_2:,
        city:,
        state:,
        zip_code:
      }

      expect(object.address).to eq(Flex::Address.new(street_line_1:, street_line_2:, city:, state:, zip_code:))
      expect(object.address_street_line_1).to eq(street_line_1)
      expect(object.address_street_line_2).to eq(street_line_2)
      expect(object.address_city).to eq(city)
      expect(object.address_state).to eq(state)
      expect(object.address_zip_code).to eq(zip_code)
    end

    it "allows setting nested address attributes directly" do
      object.address_street_line_1 = street_line_1
      object.address_street_line_2 = street_line_2
      object.address_city = city
      object.address_state = state
      object.address_zip_code = zip_code
      expect(object.address).to eq(Flex::Address.new(street_line_1:, street_line_2:, city:, state:, zip_code:))
    end

    it "preserves values exactly as entered without normalization" do
      object.address = {
        street_line_1: "789 BROADWAY",
        street_line_2: "",
        city: "new york",
        state: "NY",
        zip_code: "10003"
      }

      expect(object.address).to eq(Flex::Address.new(street_line_1: "789 BROADWAY", street_line_2: "", city: "new york", state: "NY", zip_code: "10003"))
      expect(object.address_street_line_1).to eq("789 BROADWAY")
      expect(object.address_street_line_2).to eq("")
      expect(object.address_city).to eq("new york")
      expect(object.address_state).to eq("NY")
      expect(object.address_zip_code).to eq("10003")
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers

  describe "array attributes" do
    let(:object) { TestRecord.new }

    describe "addresses array" do
      it "allows setting an array of addresses" do
        addresses = [
          build(:address, :base),
          build(:address, :base)
        ]
        object.addresses = addresses

        expect(object.addresses).to be_an(Array)
        expect(object.addresses.size).to eq(2)
        expect(object.addresses[0]).to eq(addresses[0])
        expect(object.addresses[1]).to eq(addresses[1])
      end

      it "validates each address in the array" do
        object.addresses = [
          Flex::Address.new(street_line_1: "123 Main St", state: "MA", zip_code: "02108"), # Invalid: missing city
          build(:address, :base) # Valid
        ]

        expect(object).not_to be_valid
        expect(object.errors[:addresses]).to include("contains one or more invalid items")
      end
    end

    describe "leave_periods array" do
      it "allows setting an array of date ranges" do
        periods = [
          Flex::DateRange.new(Flex::USDate.new(2023, 1, 1), Flex::USDate.new(2023, 1, 31)),
          Flex::DateRange.new(Flex::USDate.new(2023, 2, 1), Flex::USDate.new(2023, 2, 28))
        ]
        object.leave_periods = periods
        expect(object.leave_periods).to be_an(Array)
        expect(object.leave_periods.size).to eq(2)
        expect(object.leave_periods[0]).to eq(Flex::DateRange.new(Flex::USDate.new(2023, 1, 1), Flex::USDate.new(2023, 1, 31)))
        expect(object.leave_periods[1]).to eq(Flex::DateRange.new(Flex::USDate.new(2023, 2, 1), Flex::USDate.new(2023, 2, 28)))
      end
    end

    describe "names array" do
      it "allows setting an array of names" do
        names = [
          Flex::Name.new(first: "John", last: "Smith"),
          Flex::Name.new(first: "Jane", middle: "Marie", last: "Doe")
        ]
        object.names = names

        expect(object.names).to be_an(Array)
        expect(object.names.size).to eq(2)
        expect(object.names[0]).to eq(names[0])
        expect(object.names[1]).to eq(names[1])
      end
    end

    describe "reporting_periods array" do
      it "allows setting an array of year quarters" do
        periods = [
          Flex::YearQuarter.new(2023, 1),
          Flex::YearQuarter.new(2023, 2)
        ]
        object.reporting_periods = periods

        expect(object.reporting_periods).to be_an(Array)
        expect(object.reporting_periods.size).to eq(2)
        expect(object.reporting_periods[0]).to eq(periods[0])
        expect(object.reporting_periods[1]).to eq(periods[1])
      end

      it "validates each year quarter in the array" do
        object.reporting_periods = [
          Flex::YearQuarter.new(2023, 5), # Invalid: quarter > 4
          Flex::YearQuarter.new(2023, 2)  # Valid
        ]

        expect(object).not_to be_valid
        expect(object.errors[:reporting_periods]).to include("contains one or more invalid items")
      end
    end

    describe "persistence" do
      let(:record) { TestRecord.new }

      it "persists and loads arrays of value objects" do
        address_1 = build(:address, :base)
        address_2 = build(:address, :base)
        record.addresses = [ address_1, address_2 ]

        name_1 = build(:name, :base)
        name_2 = build(:name, :base, :with_middle)
        record.names = [ name_1, name_2 ]

        year_quarter_1 = build(:year_quarter)
        year_quarter_2 = build(:year_quarter)
        record.reporting_periods = [ year_quarter_1, year_quarter_2 ]

        leave_period_1 = Flex::DateRange.new(Flex::USDate.new(2023, 1, 1), Flex::USDate.new(2023, 1, 31))
        leave_period_2 = Flex::DateRange.new(Flex::USDate.new(2023, 2, 1), Flex::USDate.new(2023, 2, 28))
        record.leave_periods = [ leave_period_1, leave_period_2 ]

        record.save!
        loaded_record = TestRecord.find(record.id)

        expect(loaded_record.addresses.size).to eq(2)
        expect(loaded_record.addresses[0]).to eq(address_1)
        expect(loaded_record.addresses[1]).to eq(address_2)

        expect(loaded_record.names.size).to eq(2)
        expect(loaded_record.names[0]).to eq(name_1)
        expect(loaded_record.names[1]).to eq(name_2)

        expect(loaded_record.reporting_periods.size).to eq(2)
        expect(loaded_record.reporting_periods[0]).to eq(year_quarter_1)
        expect(loaded_record.reporting_periods[1]).to eq(year_quarter_2)

        expect(loaded_record.leave_periods.size).to eq(2)
        expect(loaded_record.leave_periods[0]).to eq(leave_period_1)
        expect(loaded_record.leave_periods[1]).to eq(leave_period_2)
      end
    end
  end

  describe "memorable_date attribute" do
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

  describe "name attribute" do
    let(:first) { "Jane" }
    let(:middle) { "Marie" }
    let(:last) { "Doe" }

    it "allows setting name as a value object" do
      name = Flex::Name.new(first:, middle:, last:)
      object.name = name

      expect(object.name).to eq(Flex::Name.new(first:, middle:, last:))
      expect(object.name_first).to eq(first)
      expect(object.name_middle).to eq(middle)
      expect(object.name_last).to eq(last)
    end

    it "allows setting name as a hash" do
      object.name = { first: first, middle: middle, last: last }

      expect(object.name).to eq(Flex::Name.new(first:, middle:, last:))
      expect(object.name_first).to eq(first)
      expect(object.name_middle).to eq(middle)
      expect(object.name_last).to eq(last)
    end

    it "allows setting nested name attributes directly" do
      object.name_first = first
      object.name_middle = middle
      object.name_last = last
      expect(object.name).to eq(Flex::Name.new(first:, middle:, last:))
    end

    it "preserves values exactly as entered without normalization" do
      object.name = { first: "jean-luc", middle: "von", last: "O'REILLY" }

      expect(object.name).to eq(Flex::Name.new(first: "jean-luc", middle: "von", last: "O'REILLY"))
      expect(object.name_first).to eq("jean-luc")
      expect(object.name_middle).to eq("von")
      expect(object.name_last).to eq("O'REILLY")
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

  describe "us_date attribute" do
    [
      [ "allows setting as a Flex::USDate object", Flex::USDate.new(2023, 5, 15), Flex::USDate.new(2023, 5, 15) ],
      [ "allows setting as a string in MM/DD/YYYY format", "05/15/2023", Flex::USDate.new(2023, 5, 15) ],
      [ "allows setting nil", nil, nil ]
    ].each do |description, value, expected|
      it description do
        object.adopted_on = value
        expect(object.adopted_on).to eq(expected)
      end
    end
  end

  describe "us_date attribute with range option" do
    it "allows setting period as a Flex::DateRange object" do
      object.period = Flex::DateRange.new(Flex::USDate.new(2023, 1, 1), Flex::USDate.new(2023, 12, 31))

      expect(object.period).to eq(Flex::DateRange.new(Flex::USDate.new(2023, 1, 1), Flex::USDate.new(2023, 12, 31)))
      expect(object.period_start).to eq(Flex::USDate.new(2023, 1, 1))
      expect(object.period_end).to eq(Flex::USDate.new(2023, 12, 31))
      expect(object.period.start).to eq(Flex::USDate.new(2023, 1, 1))
      expect(object.period.end).to eq(Flex::USDate.new(2023, 12, 31))
    end

    it "allows setting period as a hash" do
      object.period = { start: Flex::USDate.new(2023, 6, 1), end: Flex::USDate.new(2023, 8, 31) }

      expect(object.period).to eq(Flex::DateRange.new(Flex::USDate.new(2023, 6, 1), Flex::USDate.new(2023, 8, 31)))
      expect(object.period_start).to eq(Flex::USDate.new(2023, 6, 1))
      expect(object.period_end).to eq(Flex::USDate.new(2023, 8, 31))
    end

    it "allows setting period with string keys" do
      object.period = { "start" => Flex::USDate.new(2023, 3, 1), "end" => Flex::USDate.new(2023, 5, 31) }

      expect(object.period).to eq(Flex::DateRange.new(Flex::USDate.new(2023, 3, 1), Flex::USDate.new(2023, 5, 31)))
      expect(object.period_start).to eq(Flex::USDate.new(2023, 3, 1))
      expect(object.period_end).to eq(Flex::USDate.new(2023, 5, 31))
    end

    it "allows setting nested period attributes directly" do
      object.period_start = Flex::USDate.new(2023, 9, 1)
      object.period_end = Flex::USDate.new(2023, 11, 30)
      expect(object.period).to eq(Flex::DateRange.new(Flex::USDate.new(2023, 9, 1), Flex::USDate.new(2023, 11, 30)))
    end

    it "handles nil values gracefully" do
      object.period = nil
      expect(object.period).to be_nil
      expect(object.period_start).to be_nil
      expect(object.period_end).to be_nil
    end

    it "handles partial periods" do
      object.period = { start: Flex::USDate.new(2023, 1, 1), end: nil }
      expect(object.period).to eq(Flex::DateRange.new(Flex::USDate.new(2023, 1, 1), nil))
      expect(object.period_start).to eq(Flex::USDate.new(2023, 1, 1))
      expect(object.period_end).to be_nil

      object.period = Flex::DateRange.new(nil, Flex::USDate.new(2023, 12, 31))
      expect(object.period).to eq(Flex::DateRange.new(nil, Flex::USDate.new(2023, 12, 31)))
      expect(object.period_start).to be_nil
      expect(object.period_end).to eq(Flex::USDate.new(2023, 12, 31))
    end

    it "validates that start date is before or equal to end date" do
      object.period_start = Flex::USDate.new(2023, 12, 31)
      object.period_end = Flex::USDate.new(2023, 1, 1)
      expect(object).not_to be_valid
      expect(object.errors.full_messages_for("period")).to include("Period start date cannot be after end date")
    end

    it "allows start date equal to end date" do
      same_date = Flex::USDate.new(2023, 6, 15)
      object.period_start = same_date
      object.period_end = same_date
      expect(object).to be_valid
      expect(object.period).to eq(Flex::DateRange.new(same_date, same_date))
    end

    it "allows only one date to be present" do
      object.period_start = Flex::USDate.new(2023, 1, 1)
      object.period_end = nil
      expect(object).to be_valid

      object.period_start = nil
      object.period_end = Flex::USDate.new(2023, 12, 31)
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
      [ "allows setting period as a Ruby Range of dates", Date.new(2023, 1, 1), Date.new(2023, 12, 31), Flex::DateRange.new(Flex::USDate.new(2023, 1, 1), Flex::USDate.new(2023, 12, 31)) ],
      [ "allows setting period as a Ruby Range of dates with same start and end", Date.new(2023, 6, 15), Date.new(2023, 6, 15), Flex::DateRange.new(Flex::USDate.new(2023, 6, 15), Flex::USDate.new(2023, 6, 15)) ],
      [ "allows setting period as a Ruby Range of dates with nil start", nil, Date.new(2023, 12, 31), Flex::DateRange.new(nil, Flex::USDate.new(2023, 12, 31)) ],
      [ "allows setting period as a Ruby Range of dates with nil end", Date.new(2023, 1, 1), nil, Flex::DateRange.new(Flex::USDate.new(2023, 1, 1), nil) ],
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
      expect(object.errors.full_messages_for("reporting_period_quarter")).to include("Reporting period quarter must be in 1..4")

      object.reporting_period_quarter = 0
      expect(object).not_to be_valid
      expect(object.errors.full_messages_for("reporting_period_quarter")).to include("Reporting period quarter must be in 1..4")

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

  # rubocop:disable RSpec/MultipleMemoizedHelpers
  describe "year_quarter with range option" do
    let(:start_year) { 2023 }
    let(:start_quarter) { 1 }
    let(:end_year) { 2023 }
    let(:end_quarter) { 4 }
    let(:start_value) { Flex::YearQuarter.new(start_year, start_quarter) }
    let(:end_value) { Flex::YearQuarter.new(end_year, end_quarter) }
    let(:range) { Flex::YearQuarterRange.new(start_value, end_value) }

    it "allows setting a ValueRange object" do
      object.base_period = range

      expect(object.base_period).to eq(Flex::YearQuarterRange.new(start_value, end_value))
      expect(object.base_period_start).to eq(start_value)
      expect(object.base_period_end).to eq(end_value)
      expect(object.base_period_start_year).to eq(start_year)
      expect(object.base_period_start_quarter).to eq(start_quarter)
      expect(object.base_period_end_year).to eq(end_year)
      expect(object.base_period_end_quarter).to eq(end_quarter)
    end

    it "allows setting a Range object" do
      object.base_period = start_value..end_value

      expect(object.base_period).to eq(Flex::YearQuarterRange.new(start_value, end_value))
      expect(object.base_period_start).to eq(start_value)
      expect(object.base_period_end).to eq(end_value)
      expect(object.base_period_start_year).to eq(start_year)
      expect(object.base_period_start_quarter).to eq(start_quarter)
      expect(object.base_period_end_year).to eq(end_year)
      expect(object.base_period_end_quarter).to eq(end_quarter)
    end

    it "allows setting start and end attributes directly" do
      object.base_period_start = start_value
      object.base_period_end = end_value

      expect(object.base_period).to eq(Flex::YearQuarterRange.new(start_value, end_value))
      expect(object.base_period_start).to eq(start_value)
      expect(object.base_period_end).to eq(end_value)
      expect(object.base_period_start_year).to eq(start_year)
      expect(object.base_period_start_quarter).to eq(start_quarter)
      expect(object.base_period_end_year).to eq(end_year)
      expect(object.base_period_end_quarter).to eq(end_quarter)
    end

    it "allows setting start_year, start_quarter, end_year, and end_quarter attributes directly" do
      object.base_period_start_year = start_year
      object.base_period_start_quarter = start_quarter
      object.base_period_end_year = end_year
      object.base_period_end_quarter = end_quarter

      expect(object.base_period).to eq(Flex::YearQuarterRange.new(start_value, end_value))
      expect(object.base_period_start).to eq(start_value)
      expect(object.base_period_end).to eq(end_value)
      expect(object.base_period_start_year).to eq(start_year)
      expect(object.base_period_start_quarter).to eq(start_quarter)
      expect(object.base_period_end_year).to eq(end_year)
      expect(object.base_period_end_quarter).to eq(end_quarter)
    end

    it "validates quarter values are between 1 and 4" do
      object.reporting_period_quarter = 5
      expect(object).not_to be_valid
      expect(object.errors.full_messages_for("reporting_period_quarter")).to include("Reporting period quarter must be in 1..4")

      object.reporting_period_quarter = 0
      expect(object).not_to be_valid
      expect(object.errors.full_messages_for("reporting_period_quarter")).to include("Reporting period quarter must be in 1..4")

      object.reporting_period_quarter = 2
      expect(object).to be_valid
    end
  end
  # rubocop:enable RSpec/TooManyMemoizedHelpers

  describe "base_period attribute" do
    it "allows setting base_period as a Range object" do
      start_value = Flex::YearQuarter.new(2023, 1)
      end_value = Flex::YearQuarter.new(2023, 4)
      object.base_period = start_value..end_value

      expect(object.base_period).to eq(Flex::YearQuarterRange.new(start_value, end_value))
      expect(object.base_period_start).to eq(start_value)
      expect(object.base_period_end).to eq(end_value)
    end

    it "allows setting nested base_period attributes directly" do
      start_value = Flex::YearQuarter.new(2023, 2)
      end_value = Flex::YearQuarter.new(2024, 1)
      object.base_period_start = start_value
      object.base_period_end = end_value
      expect(object.base_period).to eq(Flex::YearQuarterRange.new(start_value, end_value))
    end

    it "handles nil values gracefully" do
      object.base_period = nil
      expect(object.base_period).to be_nil
      expect(object.base_period_start).to be_nil
      expect(object.base_period_end).to be_nil
    end

    it "validates that start year quarter is before or equal to end year quarter" do
      object.base_period_start = Flex::YearQuarter.new(2024, 4)
      object.base_period_end = Flex::YearQuarter.new(2023, 1)
      expect(object).not_to be_valid
      expect(object.errors.full_messages_for("base_period")).to include("Base period start cannot be after end")
    end

    it "allows start year quarter equal to end year quarter" do
      same_yq = Flex::YearQuarter.new(2023, 3)
      object.base_period_start = same_yq
      object.base_period_end = same_yq
      expect(object).to be_valid
      expect(object.base_period).to eq(Flex::ValueRange[Flex::YearQuarter].new(same_yq, same_yq))
    end

    it "allows only one year quarter to be present without validation error" do
      object.base_period_start = Flex::YearQuarter.new(2023, 1)
      object.base_period_end = nil
      expect(object).to be_valid

      object.base_period_start = nil
      object.base_period_end = Flex::YearQuarter.new(2023, 4)
      expect(object).to be_valid
    end
  end

  describe "persisting and loading from database" do
    let(:record) { TestRecord.new }

    it "persists and loads name object correctly" do
      name = Flex::Name.new(first: "John", middle: "Middle", last: "Doe")
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
      address = Flex::Address.new(street_line_1: "123 Main St", street_line_2: "Apt 4B", city: "Boston", state: "MA", zip_code: "02108")
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
      expect(loaded_record.period).to eq(Flex::DateRange.new(Flex::USDate.new(2023, 1, 1), Flex::USDate.new(2023, 12, 31)))
      expect(loaded_record.period_start).to eq(Date.new(2023, 1, 1))
      expect(loaded_record.period_end).to eq(Date.new(2023, 12, 31))
      expect(loaded_record.period.start).to eq(Date.new(2023, 1, 1))
      expect(loaded_record.period.end).to eq(Date.new(2023, 12, 31))

      record.period_start = "01/05/2023"
      record.period_end = "06/12/2023"
      record.save!

      loaded_record = TestRecord.find(record.id)
      expect(loaded_record.period).to eq(Flex::DateRange.new(Flex::USDate.new(2023, 1, 5), Flex::USDate.new(2023, 6, 12)))
      expect(loaded_record.period_start).to eq(Date.new(2023, 1, 5))
      expect(loaded_record.period_end).to eq(Date.new(2023, 6, 12))
      expect(loaded_record.period.start).to eq(Date.new(2023, 1, 5))
      expect(loaded_record.period.end).to eq(Date.new(2023, 6, 12))
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

    it "persists and loads year_quarter_range object correctly" do
      start_year = 2023
      start_quarter = 1
      end_year = 2023
      end_quarter = 4
      start_value = Flex::YearQuarter.new(start_year, start_quarter)
      end_value = Flex::YearQuarter.new(end_year, end_quarter)
      range = Flex::YearQuarterRange.new(start_value, end_value)
      record.base_period = range
      record.save!

      loaded_record = TestRecord.find(record.id)

      expect(loaded_record.base_period_start_year).to eq(start_year)
      expect(loaded_record.base_period_start_quarter).to eq(start_quarter)
      expect(loaded_record.base_period_end_year).to eq(end_year)
      expect(loaded_record.base_period_end_quarter).to eq(end_quarter)
      expect(loaded_record.base_period_start).to eq(start_value)
      expect(loaded_record.base_period_end).to eq(end_value)
      expect(loaded_record.base_period).to eq(range)
    end

    it "preserves all attributes when saving and loading multiple value objects" do
      name = build(:name, :with_middle)
      address = build(:address, :base, :with_street_line_2)
      record.name = name
      record.address = address
      record.tax_id = Flex::TaxId.new("987-65-4321")
      record.weekly_wage = Flex::Money.new(5000)
      record.date_of_birth = Flex::USDate.new(1990, 3, 15)
      record.period = Flex::DateRange.new(Flex::USDate.new(2023, 1, 1), Flex::USDate.new(2023, 12, 31))
      record.save!

      loaded_record = TestRecord.find(record.id)

      # Verify name
      expect(loaded_record.name).to eq(name)
      expect(loaded_record.name_first).to eq(name.first)
      expect(loaded_record.name_middle).to eq(name.middle)
      expect(loaded_record.name_last).to eq(name.last)

      # Verify address
      expect(loaded_record.address).to eq(address)
      expect(loaded_record.address_street_line_1).to eq(address.street_line_1)
      expect(loaded_record.address_street_line_2).to eq(address.street_line_2)
      expect(loaded_record.address_city).to eq(address.city)
      expect(loaded_record.address_state).to eq(address.state)
      expect(loaded_record.address_zip_code).to eq(address.zip_code)

      # Verify tax_id
      expect(loaded_record.tax_id).to eq(Flex::TaxId.new("987-65-4321"))
      expect(loaded_record.tax_id.formatted).to eq("987-65-4321")

      # Verify money
      expect(loaded_record.weekly_wage).to eq(Flex::Money.new(5000))
      expect(loaded_record.weekly_wage.cents_amount).to eq(5000)
      expect(loaded_record.weekly_wage.dollar_amount).to eq(50.0)

      # Verify date_of_birth
      expect(loaded_record.date_of_birth).to eq(Flex::USDate.new(1990, 3, 15))

      # Verify date_range
      expect(loaded_record.period).to eq(Flex::DateRange.new(Flex::USDate.new(2023, 1, 1), Flex::USDate.new(2023, 12, 31)))
      expect(loaded_record.period_start).to eq(Flex::USDate.new(2023, 1, 1))
      expect(loaded_record.period_end).to eq(Flex::USDate.new(2023, 12, 31))
    end
  end
end
