require "rails_helper"

RSpec.describe Flex::YearQuarter do
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

    it "is invalid with non-integer quarters" do
      year_quarter = described_class.new(year: 2023, quarter: 1.5)
      expect(year_quarter).not_to be_valid
      expect(year_quarter.errors[:quarter]).to include("must be an integer")
    end
  end
end
