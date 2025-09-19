require "rails_helper"

RSpec.describe Strata::YearQuarter do
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
      expect { yq + 0.5 }.to raise_error(TypeError, "Integer expected, got Float")
    end

    it "raises TypeError when trying to coerce non-integer numbers" do
      yq = described_class.new(year: 2023, quarter: 2)
      expect { 0.5 + yq }.to raise_error(TypeError, "Integer expected, got Float")
      expect { 0.5 - yq }.to raise_error(TypeError, "Integer expected, got Float")
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
      [ "calculates correct date ranges for Q1", described_class.new(year: 2023, quarter: 1), Strata::DateRange.new(start: Strata::USDate.new(2023, 1, 1), end: Strata::USDate.new(2023, 3, 31)) ],
      [ "calculates correct date ranges for Q2", described_class.new(year: 2023, quarter: 2), Strata::DateRange.new(start: Strata::USDate.new(2023, 4, 1), end: Strata::USDate.new(2023, 6, 30)) ],
      [ "calculates correct date ranges for Q3", described_class.new(year: 2023, quarter: 3), Strata::DateRange.new(start: Strata::USDate.new(2023, 7, 1), end: Strata::USDate.new(2023, 9, 30)) ],
      [ "calculates correct date ranges for Q4", described_class.new(year: 2023, quarter: 4), Strata::DateRange.new(start: Strata::USDate.new(2023, 10, 1), end: Strata::USDate.new(2023, 12, 31)) ]
    ].each do |description, year_quarter, expected|
      it description do
        expect(year_quarter.to_date_range).to eq(expected)
      end
    end

    it "raises when quarter is not 1, 2, 3, or 4" do
      expect { described_class.new(year: 2023, quarter: 5).to_date_range }.to raise_error(ArgumentError, "Quarter must be 1, 2, 3, or 4")
    end
  end

  describe "to_s" do
    it "returns the year and quarter as a string" do
      expect(described_class.new(year: 2023, quarter: 2).to_s).to eq("2023Q02")
    end
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

    [
      [
        "returns nil when comparing with nil year",
        described_class.new(year: nil, quarter: 1),
        described_class.new(year: 2023, quarter: 1),
        nil
      ],
      [
        "returns nil when comparing with nil quarter",
        described_class.new(year: 2023, quarter: nil),
        described_class.new(year: 2023, quarter: 1),
        nil
      ],
      [
        "returns nil when both years are nil and quarters differ",
        described_class.new(year: nil, quarter: 1),
        described_class.new(year: nil, quarter: 2),
        nil
      ],
      [
        "returns nil when both quarters are nil and years differ",
        described_class.new(year: 2023, quarter: nil),
        described_class.new(year: 2024, quarter: nil),
        nil
      ],
      [
        "returns 0 when both year and quarter are nil",
        described_class.new(year: nil, quarter: nil),
        described_class.new(year: nil, quarter: nil),
        0
      ],
      [
        "returns 0 when both have nil year and same quarter",
        described_class.new(year: nil, quarter: 1),
        described_class.new(year: nil, quarter: 1),
        0
      ],
      [
        "returns 0 when both have nil quarter and same year",
        described_class.new(year: 2023, quarter: nil),
        described_class.new(year: 2023, quarter: nil),
        0
      ]
    ].each do |description, a, b, expected|
      it description do
        expect(a <=> b).to eq(expected)
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
end
