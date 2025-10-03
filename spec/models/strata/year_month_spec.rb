# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::YearMonth do
  let(:object) { TestRecord.new }

  describe "initialization" do
    it "accepts year and month as integers" do
      year_month = described_class.new(year: 2023, month: 6)
      expect(year_month.year).to eq(2023)
      expect(year_month.month).to eq(6)
    end

    it "accepts year and month as strings" do
      year_month = described_class.new(year: "2023", month: "6")
      expect(year_month.year).to eq(2023)
      expect(year_month.month).to eq(6)
    end
  end

  describe "+" do
    [
      [ "adds months correctly", described_class.new(year: 2023, month: 6), 1, described_class.new(year: 2023, month: 7) ],
      [ "adds months across year boundaries", described_class.new(year: 2023, month: 12), 1, described_class.new(year: 2024, month: 1) ],
      [ "supports commutative operations with coerce", 1, described_class.new(year: 2023, month: 6), described_class.new(year: 2023, month: 7) ]
    ].each do |description, year_month, n, expected|
      it description do
        expect(year_month + n).to eq(expected)
      end
    end

    it "raises TypeError for non-integer arguments" do
      year_month = described_class.new(year: 2023, month: 6)
      expect { year_month + "1" }.to raise_error(TypeError)
      expect { year_month + 0.5 }.to raise_error(TypeError)
    end

    it "raises TypeError when trying to coerce non-integer numbers" do
      year_month = described_class.new(year: 2023, month: 6)
      expect { 0.5 + year_month }.to raise_error(TypeError, "Integer expected, got Float")
      expect { 0.5 - year_month }.to raise_error(TypeError, "Integer expected, got Float")
    end
  end

  describe "-" do
    [
      [ "subtracts months correctly", described_class.new(year: 2023, month: 7), 1, described_class.new(year: 2023, month: 6) ],
      [ "subtracts months across year boundaries", described_class.new(year: 2023, month: 1), 1, described_class.new(year: 2022, month: 12) ]
    ].each do |description, year_month, n, expected|
      it description do
        expect(year_month - n).to eq(expected)
      end
    end
  end

  describe "to_date_range" do
    [
      [ "calculates correct date range for January", described_class.new(year: 2023, month: 1), Strata::DateRange.new(start: Strata::USDate.new(2023, 1, 1), end: Strata::USDate.new(2023, 1, 31)) ],
      [ "calculates correct date range for April", described_class.new(year: 2023, month: 4), Strata::DateRange.new(start: Strata::USDate.new(2023, 4, 1), end: Strata::USDate.new(2023, 4, 30)) ],
      [ "calculates correct date range for February in non-leap year", described_class.new(year: 2023, month: 2), Strata::DateRange.new(start: Strata::USDate.new(2023, 2, 1), end: Strata::USDate.new(2023, 2, 28)) ],
      [ "calculates correct date range for February in leap year", described_class.new(year: 2024, month: 2), Strata::DateRange.new(start: Strata::USDate.new(2024, 2, 1), end: Strata::USDate.new(2024, 2, 29)) ]
    ].each do |description, year_month, expected|
      it description do
        expect(year_month.to_date_range).to eq(expected)
      end
    end
  end

  describe "<=>" do
    it "allows sorting year months" do
      ym1 = described_class.new(year: 2023, month: 1)
      ym2 = described_class.new(year: 2023, month: 6)
      ym3 = described_class.new(year: 2024, month: 1)

      expect([ ym2, ym3, ym1 ].sort).to eq([ ym1, ym2, ym3 ])
    end

    it "compares year months by year first, then month" do
      earlier = described_class.new(year: 2023, month: 12)
      later = described_class.new(year: 2024, month: 1)

      expect(earlier <=> later).to eq(-1)
      expect(later <=> earlier).to eq(1)
    end

    it "compares months within the same year" do
      earlier = described_class.new(year: 2023, month: 6)
      later = described_class.new(year: 2023, month: 7)

      expect(earlier <=> later).to eq(-1)
      expect(later <=> earlier).to eq(1)
    end

    [
      [
        "returns nil when comparing with nil year",
        described_class.new(year: nil, month: 6),
        described_class.new(year: 2023, month: 6),
        nil
      ],
      [
        "returns nil when comparing with nil month",
        described_class.new(year: 2023, month: nil),
        described_class.new(year: 2023, month: 6),
        nil
      ],
      [
        "returns nil when both years are nil and months differ",
        described_class.new(year: nil, month: 6),
        described_class.new(year: nil, month: 7),
        nil
      ],
      [
        "returns nil when both months are nil and years differ",
        described_class.new(year: 2023, month: nil),
        described_class.new(year: 2024, month: nil),
        nil
      ],
      [
        "returns 0 when both year and month are nil",
        described_class.new(year: nil, month: nil),
        described_class.new(year: nil, month: nil),
        0
      ],
      [
        "returns 0 when both have nil year and same month",
        described_class.new(year: nil, month: 6),
        described_class.new(year: nil, month: 6),
        0
      ],
      [
        "returns 0 when both have nil month and same year",
        described_class.new(year: 2023, month: nil),
        described_class.new(year: 2023, month: nil),
        0
      ]
    ].each do |description, a, b, expected|
      it description do
        expect(a <=> b).to eq(expected)
      end
    end
  end

  describe "validations" do
    it "is valid with months 1-12" do
      (1..12).each do |month|
        year_month = described_class.new(year: 2023, month: month)
        expect(year_month).to be_valid
      end
    end

    it "is invalid with months less than 1" do
      year_month = described_class.new(year: 2023, month: 0)
      expect(year_month).not_to be_valid
      expect(year_month.errors[:month]).to include("must be in 1..12")
    end

    it "is invalid with months greater than 12" do
      year_month = described_class.new(year: 2023, month: 13)
      expect(year_month).not_to be_valid
      expect(year_month.errors[:month]).to include("must be in 1..12")
    end
  end
end
