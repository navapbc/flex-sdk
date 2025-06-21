require "rails_helper"

RSpec.describe Flex::YearQuarter do
  let(:object) { TestRecord.new }

  describe "initialization" do
    it "accepts year and quarter as integers" do
      year_quarter = described_class.new(year: 2023, quarter: 2)
      expect(year_quarter.year).to eq(2023)
      expect(year_quarter.quarter).to eq(2)
    end

    it "accepts year and quarter as strings" do
      year_quarter = described_class.new(year: "2023", quarter: "2")
      expect(year_quarter.year).to eq(2023)
      expect(year_quarter.quarter).to eq(2)
    end
  end

  describe "+" do
    [
      [ "adds quarters correctly", described_class.new(year: 2023, quarter: 2), 1, described_class.new(year: 2023, quarter: 3) ],
      [ "adds quarters across year boundaries", described_class.new(year: 2023, quarter: 4), 1, described_class.new(year: 2024, quarter: 1) ],
      [ "supports commutative operations with coerce", 1, described_class.new(year: 2023, quarter: 2), described_class.new(year: 2023, quarter: 3) ]
    ].each do |description, year_quarter, n, expected|
      it description do
        result = year_quarter + n
        expect(result).to eq(expected)
      end
    end

    it "raises TypeError for non-integer arguments" do
      yq = described_class.new(year: 2023, quarter: 2)
      expect { yq + "invalid" }.to raise_error(TypeError, "Integer expected, got String")
    end
  end

  describe "-" do
    [
      [ "subtracts quarters correctly", described_class.new(year: 2023, quarter: 3), 1, described_class.new(year: 2023, quarter: 2) ],
      [ "subtracts quarters across year boundaries", described_class.new(year: 2023, quarter: 1), 1, described_class.new(year: 2022, quarter: 4) ]
    ].each do |description, year_quarter, n, expected|
      it description do
        result = year_quarter - n
        expect(result).to eq(expected)
      end
    end
  end

  describe "to_date_range" do
    [
      [ "calculates correct date ranges for Q1", described_class.new(year: 2023, quarter: 1), Flex::DateRange.new(start: Flex::USDate.new(2023, 1, 1), end: Flex::USDate.new(2023, 3, 31)) ],
      [ "calculates correct date ranges for Q2", described_class.new(year: 2023, quarter: 2), Flex::DateRange.new(start: Flex::USDate.new(2023, 4, 1), end: Flex::USDate.new(2023, 6, 30)) ],
      [ "calculates correct date ranges for Q3", described_class.new(year: 2023, quarter: 3), Flex::DateRange.new(start: Flex::USDate.new(2023, 7, 1), end: Flex::USDate.new(2023, 9, 30)) ],
      [ "calculates correct date ranges for Q4", described_class.new(year: 2023, quarter: 4), Flex::DateRange.new(start: Flex::USDate.new(2023, 10, 1), end: Flex::USDate.new(2023, 12, 31)) ]
    ].each do |description, year_quarter, expected|
      it description do
        expect(year_quarter.to_date_range).to eq(expected)
      end
    end
  end

  describe "validations" do
    it "is valid with quarters 1-4" do
      (1..4).each do |quarter|
        year_quarter = described_class.new(year: 2023, quarter: quarter)
        expect(year_quarter).to be_valid
      end
    end

    it "is invalid with quarters less than 1" do
      year_quarter = described_class.new(year: 2023, quarter: 0)
      expect(year_quarter).not_to be_valid
      expect(year_quarter.errors[:quarter]).to include("must be in 1..4")
    end

    it "is invalid with quarters greater than 4" do
      year_quarter = described_class.new(year: 2023, quarter: 5)
      expect(year_quarter).not_to be_valid
      expect(year_quarter.errors[:quarter]).to include("must be in 1..4")
    end

    # TODO(https://linear.app/nava-platform/issue/TSS-175/make-yearquarter-more-strict-about-types-rather-than-liberally-casting)
    # make YearQuarter more strict about types rather than liberally casting

    # it "is invalid with non-integer quarters" do
    #   year_quarter = described_class.new(year: 2023, quarter: 1.5)
    #   expect(year_quarter).not_to be_valid
    #   expect(year_quarter.errors[:quarter]).to include("must be an integer")
    # end

    # it "is invalid with strings representing non-integer quarters" do
    #   year_quarter = described_class.new(year: "2023", quarter: "1.5")
    #   expect(year_quarter).not_to be_valid
    #   expect(year_quarter.errors[:quarter]).to include("must be an integer")
    # end
  end

  describe ".<=>" do
    it "allows sorting year quarters" do
      year_quarters = [
        described_class.new(year: 2024, quarter: 3),
        described_class.new(year: 2023, quarter: 1),
        described_class.new(year: 2024, quarter: 1)
      ]

      sorted_year_quarters = year_quarters.sort
      expect(sorted_year_quarters).to eq([
        described_class.new(year: 2023, quarter: 1),
        described_class.new(year: 2024, quarter: 1),
        described_class.new(year: 2024, quarter: 3)
      ])
    end

    it "compares year quarters by year first, then quarter" do
      earlier = described_class.new(year: 2023, quarter: 4)
      later = described_class.new(year: 2024, quarter: 1)

      expect(earlier <=> later).to eq(-1)
      expect(later <=> earlier).to eq(1)
      expect(earlier <=> earlier).to eq(0)
    end

    it "compares quarters within the same year" do
      q1 = described_class.new(year: 2024, quarter: 1)
      q3 = described_class.new(year: 2024, quarter: 3)

      expect(q1 <=> q3).to eq(-1)
      expect(q3 <=> q1).to eq(1)
    end
  end

  it "persists and loads year_quarter object correctly" do
    year_quarter = described_class.new(year: 2023, quarter: 4)
    object.reporting_period = year_quarter
    object.save!

    loaded_record = TestRecord.find(object.id)
    expect(loaded_record.reporting_period).to be_a(described_class)
    expect(loaded_record.reporting_period).to eq(year_quarter)
    expect(loaded_record.reporting_period_year).to eq(2023)
    expect(loaded_record.reporting_period_quarter).to eq(4)
  end

  it "persists and loads year_quarter_range object correctly" do
    start_year = 2023
    start_quarter = 1
    end_year = 2023
    end_quarter = 4
    start_value = described_class.new(year: start_year, quarter: start_quarter)
    end_value = described_class.new(year: end_year, quarter: end_quarter)
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

  describe "array: true" do
    let(:object) { TestRecord.new }

    it "allows setting an array of year quarters" do
      periods = [
        described_class.new(year: 2023, quarter: 1),
        described_class.new(year: 2023, quarter: 2)
      ]
      object.reporting_periods = periods

      expect(object.reporting_periods).to be_an(Array)
      expect(object.reporting_periods.size).to eq(2)
      expect(object.reporting_periods[0]).to eq(periods[0])
      expect(object.reporting_periods[1]).to eq(periods[1])
    end

    it "validates each year quarter in the array" do
      object.reporting_periods = [
        described_class.new(year: 2023, quarter: 5), # Invalid: quarter > 4
        described_class.new(year: 2023, quarter: 2)  # Valid
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
