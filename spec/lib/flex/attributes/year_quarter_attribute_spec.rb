require "rails_helper"

RSpec.describe Flex::Attributes::YearQuarterAttribute do
  let(:object) { TestRecord.new }

  it "allows setting year_quarter as a value object" do
    year_quarter = Flex::YearQuarter.new(year: 2023, quarter: 2)
    object.reporting_period = year_quarter

    expect(object.reporting_period).to eq(Flex::YearQuarter.new(year: 2023, quarter: 2))
    expect(object.reporting_period_year).to eq(2023)
    expect(object.reporting_period_quarter).to eq(2)
  end

  it "allows setting year_quarter as a hash" do
    object.reporting_period = { year: 2024, quarter: 3 }

    expect(object.reporting_period).to eq(Flex::YearQuarter.new(year: 2024, quarter: 3))
    expect(object.reporting_period_year).to eq(2024)
    expect(object.reporting_period_quarter).to eq(3)
  end

  it "allows setting nested year_quarter attributes directly" do
    object.reporting_period_year = 2025
    object.reporting_period_quarter = 1
    expect(object.reporting_period).to eq(Flex::YearQuarter.new(year: 2025, quarter: 1))
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

  it "persists and loads year_quarter object correctly" do
    year_quarter = Flex::YearQuarter.new(year: 2023, quarter: 4)
    object.reporting_period = year_quarter
    object.save!

    loaded_record = TestRecord.find(object.id)
    expect(loaded_record.reporting_period).to be_a(described_class)
    expect(loaded_record.reporting_period).to eq(year_quarter)
    expect(loaded_record.reporting_period_year).to eq(2023)
    expect(loaded_record.reporting_period_quarter).to eq(4)
  end

  # rubocop:disable RSpec/MultipleMemoizedHelpers
  describe "range: true" do
    let(:start_year) { 2023 }
    let(:start_quarter) { 1 }
    let(:end_year) { 2023 }
    let(:end_quarter) { 4 }
    let(:start_value) { Flex::YearQuarter.new(year: start_year, quarter: start_quarter) }
    let(:end_value) { Flex::YearQuarter.new(year: end_year, quarter: end_quarter) }
    let(:range) { Flex::YearQuarterRange.new(start: start_value, end: end_value) }

    it "allows setting a ValueRange object" do
      object.base_period = range

      expect(object.base_period).to eq(Flex::YearQuarterRange.new(start: start_value, end: end_value))
      expect(object.base_period_start).to eq(start_value)
      expect(object.base_period_end).to eq(end_value)
      expect(object.base_period_start_year).to eq(start_year)
      expect(object.base_period_start_quarter).to eq(start_quarter)
      expect(object.base_period_end_year).to eq(end_year)
      expect(object.base_period_end_quarter).to eq(end_quarter)
    end

    it "allows setting a Range object" do
      object.base_period = start_value..end_value

      expect(object.base_period).to eq(Flex::YearQuarterRange.new(start: start_value, end: end_value))
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

      expect(object.base_period).to eq(Flex::YearQuarterRange.new(start: start_value, end: end_value))
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

      expect(object.base_period).to eq(Flex::YearQuarterRange.new(start: start_value, end: end_value))
      expect(object.base_period_start).to eq(start_value)
      expect(object.base_period_end).to eq(end_value)
      expect(object.base_period_start_year).to eq(start_year)
      expect(object.base_period_start_quarter).to eq(start_quarter)
      expect(object.base_period_end_year).to eq(end_year)
      expect(object.base_period_end_quarter).to eq(end_quarter)
    end

    it "handles nil values gracefully" do
      object.base_period = nil
      expect(object.base_period).to be_nil
      expect(object.base_period_start).to be_nil
      expect(object.base_period_end).to be_nil
      expect(object.base_period_start_year).to be_nil
      expect(object.base_period_start_quarter).to be_nil
      expect(object.base_period_end_year).to be_nil
      expect(object.base_period_end_quarter).to be_nil
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

    it "validates that start year quarter is before or equal to end year quarter" do
      object.base_period_start = Flex::YearQuarter.new(year: 2024, quarter: 4)
      object.base_period_end = Flex::YearQuarter.new(year: 2023, quarter: 1)
      expect(object).not_to be_valid
      expect(object.errors.full_messages_for("base_period")).to include("Base period start cannot be after end")
    end

    it "allows start year quarter equal to end year quarter" do
      same_yq = Flex::YearQuarter.new(year: 2023, quarter: 3)
      object.base_period_start = same_yq
      object.base_period_end = same_yq
      expect(object).to be_valid
      expect(object.base_period).to eq(Flex::ValueRange[Flex::YearQuarter].new(start: same_yq, end: same_yq))
    end

    it "allows only one year quarter to be present without validation error" do
      object.base_period_start = Flex::YearQuarter.new(year: 2023, quarter: 1)
      object.base_period_end = nil
      expect(object).to be_valid

      object.base_period_start = nil
      object.base_period_end = Flex::YearQuarter.new(year: 2023, quarter: 4)
      expect(object).to be_valid
    end

    it "persists and loads year_quarter_range object correctly" do
      start_year = 2023
      start_quarter = 1
      end_year = 2023
      end_quarter = 4
      start_value = Flex::YearQuarter.new(year: start_year, quarter: start_quarter)
      end_value = Flex::YearQuarter.new(year: end_year, quarter: end_quarter)
      range = Flex::YearQuarterRange.new(start: start_value, end: end_value)
      object.base_period = range
      object.save!

      loaded_record = TestRecord.find(object.id)

      expect(loaded_record.base_period_start_year).to eq(start_year)
      expect(loaded_record.base_period_start_quarter).to eq(start_quarter)
      expect(loaded_record.base_period_end_year).to eq(end_year)
      expect(loaded_record.base_period_end_quarter).to eq(end_quarter)
      expect(loaded_record.base_period_start).to eq(start_value)
      expect(loaded_record.base_period_end).to eq(end_value)
      expect(loaded_record.base_period).to eq(range)
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers

  describe "array: true" do
    it "allows setting an array of year quarters" do
      periods = [
        Flex::YearQuarter.new(year: 2023, quarter: 1),
        Flex::YearQuarter.new(year: 2023, quarter: 2)
      ]
      object.reporting_periods = periods

      expect(object.reporting_periods).to be_an(Array)
      expect(object.reporting_periods.size).to eq(2)
      expect(object.reporting_periods[0]).to eq(periods[0])
      expect(object.reporting_periods[1]).to eq(periods[1])
    end

    it "validates each year quarter in the array" do
      object.reporting_periods = [
        Flex::YearQuarter.new(year: 2023, quarter: 5), # Invalid: quarter > 4
        Flex::YearQuarter.new(year: 2023, quarter: 2)  # Valid
      ]

      expect(object).not_to be_valid
      expect(object.errors[:reporting_periods]).to include("contains one or more invalid items")
    end

    it "persists and loads arrays of value objects" do
      year_quarter_1 = build(:year_quarter)
      year_quarter_2 = build(:year_quarter)
      object.reporting_periods = [ year_quarter_1, year_quarter_2 ]

      object.save!
      loaded_record = TestRecord.find(object.id)

      expect(loaded_record.reporting_periods.size).to eq(2)
      expect(loaded_record.reporting_periods[0]).to eq(year_quarter_1)
      expect(loaded_record.reporting_periods[1]).to eq(year_quarter_2)
    end
  end
end
