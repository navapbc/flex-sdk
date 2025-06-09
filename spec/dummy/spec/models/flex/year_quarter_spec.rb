require "rails_helper"

RSpec.describe Flex::YearQuarter do
  describe "arithmetic operations" do
    it "adds quarters correctly" do
      yq = described_class.new(2023, 2)
      result = yq + 1
      expect(result.year).to eq(2023)
      expect(result.quarter).to eq(3)
    end

    it "adds quarters across year boundaries" do
      yq = described_class.new(2023, 4)
      result = yq + 1
      expect(result.year).to eq(2024)
      expect(result.quarter).to eq(1)
    end

    it "subtracts quarters correctly" do
      yq = described_class.new(2023, 3)
      result = yq - 1
      expect(result.year).to eq(2023)
      expect(result.quarter).to eq(2)
    end

    it "subtracts quarters across year boundaries" do
      yq = described_class.new(2023, 1)
      result = yq - 1
      expect(result.year).to eq(2022)
      expect(result.quarter).to eq(4)
    end

    it "supports commutative operations with coerce" do
      yq = described_class.new(2023, 2)
      result = 1 + yq
      expect(result.year).to eq(2023)
      expect(result.quarter).to eq(3)
    end

    it "raises TypeError for non-integer arguments" do
      yq = described_class.new(2023, 2)
      expect { yq + "invalid" }.to raise_error(TypeError, "Integer expected, got String")
    end
  end

  describe "to_date_range" do
    it "returns proper date range for Q2" do
      yq = described_class.new(2023, 2)
      range = yq.to_date_range
      expect(range.begin).to eq(Date.new(2023, 4, 1))
      expect(range.end).to eq(Date.new(2023, 6, 30))
    end

    it "includes dates within the quarter" do
      yq = described_class.new(2023, 2)
      range = yq.to_date_range
      expect(range.include?(Date.new(2023, 5, 15))).to be true
      expect(range.include?(Date.new(2023, 3, 15))).to be false
    end

    it "calculates correct date ranges for all quarters" do
      q1 = described_class.new(2023, 1)
      expect(q1.to_date_range.begin).to eq(Date.new(2023, 1, 1))
      expect(q1.to_date_range.end).to eq(Date.new(2023, 3, 31))

      q2 = described_class.new(2023, 2)
      expect(q2.to_date_range.begin).to eq(Date.new(2023, 4, 1))
      expect(q2.to_date_range.end).to eq(Date.new(2023, 6, 30))

      q3 = described_class.new(2023, 3)
      expect(q3.to_date_range.begin).to eq(Date.new(2023, 7, 1))
      expect(q3.to_date_range.end).to eq(Date.new(2023, 9, 30))

      q4 = described_class.new(2023, 4)
      expect(q4.to_date_range.begin).to eq(Date.new(2023, 10, 1))
      expect(q4.to_date_range.end).to eq(Date.new(2023, 12, 31))
    end
  end
end
