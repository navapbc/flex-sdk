# frozen_string_literal: true

require "rails_helper"
require_relative "value_object_attribute_shared_examples"

RSpec.describe Strata::Attributes::YearQuarterAttribute do
  include_examples "value object shared examples", described_class, Strata::YearQuarter, :reporting_period,
    valid_nested_attributes: FactoryBot.attributes_for(:year_quarter),
    array_values: [
      FactoryBot.build(:year_quarter),
      FactoryBot.build(:year_quarter)
    ],
    invalid_value: FactoryBot.build(:year_quarter, :invalid)

  describe "string assignment" do
    it "accepts string values in 'YYYYQQ' format" do
      object.reporting_period = "2025Q3"
      expect(object.reporting_period.year).to eq(2025)
      expect(object.reporting_period.quarter).to eq(3)
    end

    it "returns nil for invalid string formats" do
      object.reporting_period = "invalid"
      expect(object.reporting_period).to be_nil
    end

    it "returns nil for strings without Q separator" do
      object.reporting_period = "20251"
      expect(object.reporting_period).to be_nil
    end

    it "serializes to string format with leading zeros" do
      year_quarter = Strata::YearQuarter.new(year: 2025, quarter: 1)
      object.reporting_period = year_quarter
      object.save!

      loaded_object = TestRecord.find(object.id)
      expect(loaded_object.reporting_period.year).to eq(2025)
      expect(loaded_object.reporting_period.quarter).to eq(1)
    end
  end

  describe "validation" do
    it "validates quarter values are between 1 and 4" do
      object.reporting_period = { year: 2025, quarter: 5 }
      expect(object).not_to be_valid
      expect(object.reporting_period.errors.full_messages_for("quarter")).to include("Quarter must be in 1..4")

      object.reporting_period = { year: 2025, quarter: 0 }
      expect(object).not_to be_valid
      expect(object.reporting_period.errors.full_messages_for("quarter")).to include("Quarter must be in 1..4")

      object.reporting_period = { year: 2025, quarter: 2 }
      expect(object).to be_valid
    end

    it "validates year values are present" do
      object.reporting_period = { year: nil, quarter: 1 }
      expect(object).not_to be_valid
      expect(object.reporting_period.errors.full_messages_for("year")).to include("Year can't be blank")
    end

    it "validates assigning using a properly formatted string" do
      object.reporting_period = "asdf"
      expect(object).not_to be_valid
      expect(object.errors.full_messages_for("reporting_period")).to include("Reporting period is an invalid quarter")
    end

    [ 123, 123.45, Object.new ].each do |invalid_object|
      it "casts #{invalid_object.class} to nil and marks as invalid" do
        object.reporting_period = invalid_object
        expect(object.reporting_period).to be_nil
        expect(object).not_to be_valid
        expect(object.errors.full_messages_for("reporting_period")).to include("Reporting period is an invalid quarter")
      end
    end
  end

  describe "range: true" do
    let(:start_year) { 2023 }
    let(:start_quarter) { 1 }
    let(:end_year) { 2023 }
    let(:end_quarter) { 4 }
    let(:start_value) { Strata::YearQuarter.new(year: start_year, quarter: start_quarter) }
    let(:end_value) { Strata::YearQuarter.new(year: end_year, quarter: end_quarter) }
    let(:range) { Strata::ValueRange[Strata::YearQuarter].new(start: start_value, end: end_value) }

    it "allows setting a ValueRange object" do
      object.base_period = range

      expect(object.base_period).to eq(Strata::ValueRange[Strata::YearQuarter].new(start: start_value, end: end_value))
      expect(object.base_period_start).to eq(start_value)
      expect(object.base_period_end).to eq(end_value)
    end

    it "allows setting a Range object" do
      object.base_period = start_value..end_value

      expect(object.base_period).to eq(Strata::ValueRange[Strata::YearQuarter].new(start: start_value, end: end_value))
      expect(object.base_period_start).to eq(start_value)
      expect(object.base_period_end).to eq(end_value)
    end

    it "allows setting start and end attributes directly" do
      object.base_period_start = start_value
      object.base_period_end = end_value

      expect(object.base_period).to eq(Strata::ValueRange[Strata::YearQuarter].new(start: start_value, end: end_value))
      expect(object.base_period_start).to eq(start_value)
      expect(object.base_period_end).to eq(end_value)
    end

    it "handles nil values gracefully" do
      object.base_period = nil
      expect(object.base_period).to be_nil
      expect(object.base_period_start).to be_nil
      expect(object.base_period_end).to be_nil
    end

    it "validates quarter values are between 1 and 4" do
      object.reporting_period = { year: 2025, quarter: 5 }
      expect(object).not_to be_valid
      expect(object.reporting_period.errors.full_messages_for("quarter")).to include("Quarter must be in 1..4")

      object.reporting_period = { year: 2025, quarter: 0 }
      expect(object).not_to be_valid
      expect(object.reporting_period.errors.full_messages_for("quarter")).to include("Quarter must be in 1..4")

      object.reporting_period = { year: 2025, quarter: 2 }
      expect(object).to be_valid
    end

    it "validates that start year quarter is before or equal to end year quarter" do
      object.base_period_start = Strata::YearQuarter.new(year: 2024, quarter: 4)
      object.base_period_end = Strata::YearQuarter.new(year: 2023, quarter: 1)
      expect(object).not_to be_valid
      expect(object.errors.full_messages_for("base_period")).to include("Base period start cannot be after end")
    end

    it "allows start year quarter equal to end year quarter" do
      same_yq = Strata::YearQuarter.new(year: 2023, quarter: 3)
      object.base_period_start = same_yq
      object.base_period_end = same_yq
      expect(object).to be_valid
      expect(object.base_period).to eq(Strata::ValueRange[Strata::YearQuarter].new(start: same_yq, end: same_yq))
    end

    it "allows only one year quarter to be present without validation error" do
      object.base_period_start = Strata::YearQuarter.new(year: 2023, quarter: 1)
      object.base_period_end = nil
      expect(object).to be_valid

      object.base_period_start = nil
      object.base_period_end = Strata::YearQuarter.new(year: 2023, quarter: 4)
      expect(object).to be_valid
    end

    it "persists and loads year_quarter_range object correctly" do
      start_year = 2023
      start_quarter = 1
      end_year = 2023
      end_quarter = 4
      start_value = Strata::YearQuarter.new(year: start_year, quarter: start_quarter)
      end_value = Strata::YearQuarter.new(year: end_year, quarter: end_quarter)
      range = Strata::ValueRange[Strata::YearQuarter].new(start: start_value, end: end_value)
      object.base_period = range
      object.save!

      loaded_record = TestRecord.find(object.id)

      expect(loaded_record.base_period_start).to eq(start_value)
      expect(loaded_record.base_period_end).to eq(end_value)
      expect(loaded_record.base_period).to eq(range)
    end
  end
end
