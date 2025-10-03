# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::Attributes::USDateAttribute do
  let(:object) { TestRecord.new }

  [
    [ "allows setting as a Strata::USDate object", Strata::USDate.new(2023, 5, 15), Strata::USDate.new(2023, 5, 15) ],
    [ "allows setting as a string in MM/DD/YYYY format", "05/15/2023", Strata::USDate.new(2023, 5, 15) ],
    [ "allows setting nil", nil, nil ]
  ].each do |description, value, expected|
    it description do
      object.adopted_on = value
      expect(object.adopted_on).to eq(expected)
    end
  end

  describe "range: true" do
    it "allows setting period as a Strata::DateRange object" do
      object.period = Strata::DateRange.new(start: Strata::USDate.new(2023, 1, 1), end: Strata::USDate.new(2023, 12, 31))

      expect(object.period).to eq(Strata::DateRange.new(start: Strata::USDate.new(2023, 1, 1), end: Strata::USDate.new(2023, 12, 31)))
      expect(object.period_start).to eq(Strata::USDate.new(2023, 1, 1))
      expect(object.period_end).to eq(Strata::USDate.new(2023, 12, 31))
      expect(object.period.start).to eq(Strata::USDate.new(2023, 1, 1))
      expect(object.period.end).to eq(Strata::USDate.new(2023, 12, 31))
    end

    it "allows setting period as a hash" do
      object.period = { start: Strata::USDate.new(2023, 6, 1), end: Strata::USDate.new(2023, 8, 31) }

      expect(object.period).to eq(Strata::DateRange.new(start: Strata::USDate.new(2023, 6, 1), end: Strata::USDate.new(2023, 8, 31)))
      expect(object.period_start).to eq(Strata::USDate.new(2023, 6, 1))
      expect(object.period_end).to eq(Strata::USDate.new(2023, 8, 31))
    end

    it "allows setting period with string keys" do
      object.period = { "start" => Strata::USDate.new(2023, 3, 1), "end" => Strata::USDate.new(2023, 5, 31) }

      expect(object.period).to eq(Strata::DateRange.new(start: Strata::USDate.new(2023, 3, 1), end: Strata::USDate.new(2023, 5, 31)))
      expect(object.period_start).to eq(Strata::USDate.new(2023, 3, 1))
      expect(object.period_end).to eq(Strata::USDate.new(2023, 5, 31))
    end

    it "allows setting nested period attributes directly" do
      object.period_start = Strata::USDate.new(2023, 9, 1)
      object.period_end = Strata::USDate.new(2023, 11, 30)
      expect(object.period).to eq(Strata::DateRange.new(start: Strata::USDate.new(2023, 9, 1), end: Strata::USDate.new(2023, 11, 30)))
    end

    it "handles nil values gracefully" do
      object.period = nil
      expect(object.period).to be_nil
      expect(object.period_start).to be_nil
      expect(object.period_end).to be_nil
    end

    it "handles partial periods" do
      object.period = { start: Strata::USDate.new(2023, 1, 1) }
      expect(object.period).to eq(Strata::DateRange.new(start: Strata::USDate.new(2023, 1, 1)))
      expect(object.period_start).to eq(Strata::USDate.new(2023, 1, 1))
      expect(object.period_end).to be_nil

      object.period = Strata::DateRange.new(end: Strata::USDate.new(2023, 12, 31))
      expect(object.period).to eq(Strata::DateRange.new(end: Strata::USDate.new(2023, 12, 31)))
      expect(object.period_start).to be_nil
      expect(object.period_end).to eq(Strata::USDate.new(2023, 12, 31))
    end

    it "validates that start date is before or equal to end date" do
      object.period_start = Strata::USDate.new(2023, 12, 31)
      object.period_end = Strata::USDate.new(2023, 1, 1)
      expect(object).not_to be_valid
      expect(object.errors.full_messages_for("period")).to include("Period start date cannot be after end date")
    end

    it "allows start date equal to end date" do
      same_date = Strata::USDate.new(2023, 6, 15)
      object.period_start = same_date
      object.period_end = same_date
      expect(object).to be_valid
      expect(object.period).to eq(Strata::DateRange.new(start: same_date, end: same_date))
    end

    it "allows only one date to be present" do
      object.period_start = Strata::USDate.new(2023, 1, 1)
      object.period_end = nil
      expect(object).to be_valid

      object.period_start = nil
      object.period_end = Strata::USDate.new(2023, 12, 31)
      expect(object).to be_valid
    end

    describe "handling invalid dates" do
      it "validates invalid start date format" do
        object.period_start = "not-a-date"
        object.period_end = "2023-12-31"
        expect(object).not_to be_valid
        expect(object.period_start).to be_nil
        expect(object.errors.full_messages_for("period_start")).to include("Period start is an invalid date")
      end

      it "validates invalid end date format" do
        object.period_start = "2023-01-01"
        object.period_end = "invalid-date"
        expect(object).not_to be_valid
        expect(object.period_end).to be_nil
        expect(object.errors.full_messages_for("period_end")).to include("Period end is an invalid date")
      end

      it "validates both dates when both are invalid" do
        object.period = { start: "bad-start", end: "bad-end" }
        expect(object).not_to be_valid
        expect(object.period_start).to be_nil
        expect(object.period_end).to be_nil
        expect(object.errors.full_messages_for("period_start")).to include("Period start is an invalid date")
        expect(object.errors.full_messages_for("period_end")).to include("Period end is an invalid date")
      end

      it "handles invalid date components" do
        object.period_start = "13/45/2023"
        object.period_end = "12/31/2023"
        expect(object).not_to be_valid
        expect(object.period_start).to be_nil
        expect(object.errors.full_messages_for("period_start")).to include("Period start is an invalid date")
      end

      it "handles leap year edge cases" do
        object.period_start = "02/29/2023"
        object.period_end = "02/29/2024"
        expect(object).not_to be_valid
        expect(object.period_start).to be_nil
        expect(object.period_end).to be_a(Date)  # This date is valid since 2024 is a leap year
        expect(object.errors.full_messages_for("period_start")).to include("Period start is an invalid date")
      end
    end

    [
      [ "allows setting period as a Ruby Range of dates", Date.new(2023, 1, 1), Date.new(2023, 12, 31), Strata::DateRange.new(start: Strata::USDate.new(2023, 1, 1), end: Strata::USDate.new(2023, 12, 31)) ],
      [ "allows setting period as a Ruby Range of dates with same start and end", Date.new(2023, 6, 15), Date.new(2023, 6, 15), Strata::DateRange.new(start: Strata::USDate.new(2023, 6, 15), end: Strata::USDate.new(2023, 6, 15)) ],
      [ "allows setting period as a Ruby Range of dates with nil start", nil, Date.new(2023, 12, 31), Strata::DateRange.new(end: Strata::USDate.new(2023, 12, 31)) ],
      [ "allows setting period as a Ruby Range of dates with nil end", Date.new(2023, 1, 1), nil, Strata::DateRange.new(start: Strata::USDate.new(2023, 1, 1)) ],
      [ "allows setting period as nil..nil", nil, nil, nil ]
    ].each do |description, start_date, end_date, expected|
      it description do
        object.period = start_date..end_date

        expect(object.period).to eq(expected)
        expect(object.period_start).to eq(start_date)
        expect(object.period_end).to eq(end_date)
      end
    end

    it "ignores Range objects that don't contain dates" do
      object.period = 1..10
      expect(object.period).to be_nil
      expect(object.period_start).to be_nil
      expect(object.period_end).to be_nil
    end
  end

  it "persists and loads period object correctly" do
    object.period = Date.new(2023, 1, 1)..Date.new(2023, 12, 31)
    object.save!

    loaded_record = TestRecord.find(object.id)
    expect(loaded_record.period).to eq(Strata::DateRange.new(start: Strata::USDate.new(2023, 1, 1), end: Strata::USDate.new(2023, 12, 31)))
    expect(loaded_record.period_start).to eq(Date.new(2023, 1, 1))
    expect(loaded_record.period_end).to eq(Date.new(2023, 12, 31))
    expect(loaded_record.period.start).to eq(Date.new(2023, 1, 1))
    expect(loaded_record.period.end).to eq(Date.new(2023, 12, 31))

    object.period_start = "01/05/2023"
    object.period_end = "06/12/2023"
    object.save!

    loaded_record = TestRecord.find(object.id)
    expect(loaded_record.period).to eq(Strata::DateRange.new(start: Strata::USDate.new(2023, 1, 5), end: Strata::USDate.new(2023, 6, 12)))
    expect(loaded_record.period_start).to eq(Date.new(2023, 1, 5))
    expect(loaded_record.period_end).to eq(Date.new(2023, 6, 12))
    expect(loaded_record.period.start).to eq(Date.new(2023, 1, 5))
    expect(loaded_record.period.end).to eq(Date.new(2023, 6, 12))
  end


  describe "array: true" do
    it "persists and loads arrays of value objects" do
      leave_period_1 = Strata::DateRange.new(start: Strata::USDate.new(2023, 1, 1), end: Strata::USDate.new(2023, 1, 31))
      leave_period_2 = Strata::DateRange.new(start: Strata::USDate.new(2023, 2, 1), end: Strata::USDate.new(2023, 2, 28))
      object.leave_periods = [ leave_period_1, leave_period_2 ]

      object.save!
      loaded_record = TestRecord.find(object.id)

      expect(loaded_record.leave_periods.size).to eq(2)
      expect(loaded_record.leave_periods[0]).to eq(leave_period_1)
      expect(loaded_record.leave_periods[1]).to eq(leave_period_2)
    end
  end

  describe "array of ranges with strata_attribute [ :us_date, range: true ], array: true" do
    it "allows setting an array of date ranges" do
      periods = [
        Strata::DateRange.new(start: Strata::USDate.new(2023, 1, 1), end: Strata::USDate.new(2023, 1, 31)),
        Strata::DateRange.new(start: Strata::USDate.new(2023, 2, 1), end: Strata::USDate.new(2023, 2, 28))
      ]
      object.leave_periods = periods
      expect(object.leave_periods).to be_an(Array)
      expect(object.leave_periods.size).to eq(2)
      expect(object.leave_periods[0]).to eq(Strata::DateRange.new(start: Strata::USDate.new(2023, 1, 1), end: Strata::USDate.new(2023, 1, 31)))
      expect(object.leave_periods[1]).to eq(Strata::DateRange.new(start: Strata::USDate.new(2023, 2, 1), end: Strata::USDate.new(2023, 2, 28)))
    end
  end
end
