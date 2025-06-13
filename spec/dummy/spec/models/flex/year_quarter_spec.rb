require "rails_helper"

RSpec.describe Flex::YearQuarter do
  describe "+" do
    [
      [ "adds quarters correctly", described_class.new(2023, 2), 1, described_class.new(2023, 3) ],
      [ "adds quarters across year boundaries", described_class.new(2023, 4), 1, described_class.new(2024, 1) ],
      [ "supports commutative operations with coerce", 1, described_class.new(2023, 2), described_class.new(2023, 3) ]
    ].each do |description, year_quarter, n, expected|
      it description do
        result = year_quarter + n
        expect(result).to eq(expected)
      end
    end

    it "raises TypeError for non-integer arguments" do
      yq = described_class.new(2023, 2)
      expect { yq + "invalid" }.to raise_error(TypeError, "Integer expected, got String")
    end
  end

  describe "-" do
    [
      [ "subtracts quarters correctly", described_class.new(2023, 3), 1, described_class.new(2023, 2) ],
      [ "subtracts quarters across year boundaries", described_class.new(2023, 1), 1, described_class.new(2022, 4) ]
    ].each do |description, year_quarter, n, expected|
      it description do
        result = year_quarter - n
        expect(result).to eq(expected)
      end
    end
  end

  describe "to_date_range" do
    [
      [ "calculates correct date ranges for Q1", described_class.new(2023, 1), Flex::DateRange.new(Date.new(2023, 1, 1), Date.new(2023, 3, 31)) ],
      [ "calculates correct date ranges for Q2", described_class.new(2023, 2), Flex::DateRange.new(Date.new(2023, 4, 1), Date.new(2023, 6, 30)) ],
      [ "calculates correct date ranges for Q3", described_class.new(2023, 3), Flex::DateRange.new(Date.new(2023, 7, 1), Date.new(2023, 9, 30)) ],
      [ "calculates correct date ranges for Q4", described_class.new(2023, 4), Flex::DateRange.new(Date.new(2023, 10, 1), Date.new(2023, 12, 31)) ]
    ].each do |description, year_quarter, expected|
      it description do
        expect(year_quarter.to_date_range).to eq(expected)
      end
    end
  end
end
