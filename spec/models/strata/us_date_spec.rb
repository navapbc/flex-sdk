# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::USDate do
  describe ".cast" do
    it "returns nil when given nil" do
      expect(described_class.cast(nil)).to be_nil
    end

    it "converts a Date object to USDate" do
      date = Date.new(2023, 12, 25)
      result = described_class.cast(date)

      expect(result).to be_a(described_class)
      expect(result).to eq(date)
    end

    it "parses valid US date strings" do
      result = described_class.cast("12/25/2023")

      expect(result).to be_a(Date)
      expect(result.year).to eq(2023)
      expect(result.month).to eq(12)
      expect(result.day).to eq(25)
    end

    it "parses valid ISO date strings" do
      result = described_class.cast("2023-12-25")

      expect(result).to be_a(Date)
      expect(result.year).to eq(2023)
      expect(result.month).to eq(12)
      expect(result.day).to eq(25)
    end

    it "returns nil for invalid date strings" do
      expect(described_class.cast("invalid")).to be_nil
      expect(described_class.cast("1/32/2023")).to be_nil
      expect(described_class.cast("20/01/2023")).to be_nil
      expect(described_class.cast("13/45/2023")).to be_nil
    end
  end
end
