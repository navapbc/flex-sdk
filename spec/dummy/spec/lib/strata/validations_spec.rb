require 'rails_helper'

RSpec.describe Strata::Validations do
  let(:object) { TestRecord.new }

  describe '#strata_validates_nested' do
    let(:valid_base_period) do
      Strata::YearQuarterRange.new(
        start: Strata::YearQuarter.new(year: 2025, quarter: 1),
        end: Strata::YearQuarter.new(year: 2025, quarter: 4)
      )
    end

    let(:valid_period) do
      Strata::DateRange.new(
        start: Strata::USDate.new(2025, 6, 16),
        end: Strata::USDate.new(2025, 6, 17)
      )
    end

    context 'when nested object is valid' do
      before do
        object.base_period = valid_base_period
        object.period = valid_period
      end

      it 'is valid' do
        expect(object).to be_valid
      end

      it 'has valid nested objects' do
        expect(object.base_period).to be_valid
        expect(object.period).to be_valid
      end
    end

    context 'when nested object is nil' do
      before do
        object.base_period = nil
        object.period = nil
      end

      it 'is valid' do
        expect(object).to be_valid
      end
    end

    context 'when nested object is blank' do
      before do
        object.base_period = Strata::YearQuarterRange.new(
          start: Strata::YearQuarter.new(year: nil, quarter: nil),
          end: Strata::YearQuarter.new(year: nil, quarter: nil)
        )
        object.period = Strata::DateRange.new(
          start: nil,
          end: nil
        )
      end

      it 'is valid' do
        expect(object).to be_valid
      end
    end

    context 'when nested object has base errors' do
      before do
        object.period = Strata::DateRange.new(
          start: Strata::USDate.new(2025, 1, 1),
          end: Strata::USDate.new(2020, 1, 1)
        )
      end

      it 'adds errors under the attribute name' do
        expect(object).not_to be_valid
        expect(object.errors[:period]).to include("start date cannot be after end date")
      end
    end

    context 'when nested object has nested attribute errors' do
      before do
        object.base_period = Strata::YearQuarterRange.new(
          start: Strata::YearQuarter.new(year: 2025, quarter: 0),
          end: Strata::YearQuarter.new(year: 2025, quarter: 5)
        )
        object.activity_reporting_period = Strata::YearMonth.new(year: 2025, month: 13)
        object.period = {
          start: "1/35/2025",
          end: "2/30/2025"
        }
      end

      it 'adds errors under the attribute name with subfield' do
        expect(object).not_to be_valid
        expect(object.base_period_start.errors[:quarter]).to include("must be in 1..4")
        expect(object.base_period_end.errors[:quarter]).to include("must be in 1..4")
        expect(object.activity_reporting_period.errors[:month]).to include("must be in 1..12")
        expect(object.errors[:period_start]).to include("is an invalid date")
        expect(object.errors[:period_start]).to include("is an invalid date")
      end
    end
  end
end
