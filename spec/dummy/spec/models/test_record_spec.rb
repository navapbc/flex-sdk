require "rails_helper"

RSpec.describe TestRecord, type: :model do
  it "allows setting a Range of Date objects" do
    record = described_class.new
    start_date = Date.new(2020, 1, 2)
    end_date = Date.new(2020, 2, 3)
    record.period = start_date..end_date

    expect(record.period_start).to eq(start_date)
    expect(record.period_end).to eq(end_date)
    expect(record.period).to eq(start_date..end_date)
  end

  it "allows setting to nil" do
    record = described_class.new
    record.period = nil
    expect(record.period).to be_nil
    expect(record.period_start).to be_nil
    expect(record.period_end).to be_nil
  end

  context "when start date is after end date" do
    it "is invalid with appropriate error message" do
      record = described_class.new
      record.period_start = Date.new(2020, 2, 3)
      record.period_end = Date.new(2020, 1, 2)

      expect(record).not_to be_valid
      expect(record.errors[:period].first).to eq("Start date must be less than or equal to end date")
    end
  end

  context "with only one date set to nil" do
    it "is invalid when only start date is nil" do
      record = described_class.new
      record.period_start = nil
      record.period_end = Date.new(2020, 1, 2)

      expect(record).not_to be_valid
      expect(record.errors[:period].first).to eq("Both start and end dates must be present or both must be nil")
    end

    it "is invalid when only end date is nil" do
      record = described_class.new
      record.period_start = Date.new(2020, 1, 2)
      record.period_end = nil

      expect(record).not_to be_valid
      expect(record.errors[:period].first).to eq("Both start and end dates must be present or both must be nil")
    end
  end
end
