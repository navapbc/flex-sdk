require 'rails_helper'

RSpec.describe Flex::Validations do
  let(:object) { TestRecord.new }

  describe '#flex_validates_nested' do
    let(:valid_base_period) do
      Flex::YearQuarterRange.new(
        Flex::YearQuarter.new(2025, 1),
        Flex::YearQuarter.new(2025, 4)
      )
    end

    let(:valid_period) do
      Flex::DateRange.new(
        Flex::USDate.new(2025,6,16), 
        Flex::USDate.new(2025,6,17)
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

    context 'when nested object has base errors' do
      before do
        object.period = Flex::DateRange.new(
          Flex::USDate.new(2025,1,1),
          Flex::USDate.new(2020,1,1)
        )
      end

      it 'adds errors under the attribute name' do
        expect(object).not_to be_valid
        expect(object.errors[:period]).to include("start date cannot be after end date")
      end
    end

    context 'when nested object has nested attribute errors' do
      before do
        object.base_period = Flex::YearQuarterRange.new(
          Flex::YearQuarter.new(2025, 0),
          Flex::YearQuarter.new(2025, 5)
        )
        object.period = {
          start: "1/35/2025",
          end: "2/30/2025"
        }
      end

      it 'adds errors under the attribute name with subfield' do
        expect(object).not_to be_valid
        expect(object.errors[:base_period_start_quarter]).to include("must be in 1..4")
        expect(object.errors[:base_period_end_quarter]).to include("must be in 1..4")
        expect(object.errors[:period_start]).to include("is an invalid date")
        expect(object.errors[:period_start]).to include("is an invalid date")
      end
    end
  end
end
