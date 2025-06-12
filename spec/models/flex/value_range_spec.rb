require 'rails_helper'

RSpec.describe Flex::ValueRange do
  describe "ValueRange[Date]" do
    let(:start_date) { Date.new(2023, 1, 1) }
    let(:end_date) { Date.new(2023, 12, 31) }
    let(:date_range) { Flex::DateRange.new(start_date, end_date) }

    describe 'validations' do
      it 'is valid with valid start and end dates' do
        expect(date_range).to be_valid
      end

      it 'is invalid when start date is after end date' do
        invalid_range = Flex::DateRange.new(end_date, start_date)
        expect(invalid_range).not_to be_valid
        expect(invalid_range.errors[:base]).to include("start date cannot be after end date")
      end

      it 'is valid when dates are blank' do
        range = Flex::DateRange.new(nil, nil)
        expect(range).to be_valid
      end
    end

    describe '#include?' do
      it 'returns true for a date within the range' do
        middle_date = Date.new(2023, 6, 1)
        expect(date_range.include?(middle_date)).to be true
      end

      it 'returns true for boundary dates' do
        expect(date_range.include?(start_date)).to be true
        expect(date_range.include?(end_date)).to be true
      end

      it 'returns false for dates outside the range' do
        before_date = Date.new(2022, 12, 31)
        after_date = Date.new(2024, 1, 1)
        expect(date_range.include?(before_date)).to be false
        expect(date_range.include?(after_date)).to be false
      end
    end

    describe '#as_json' do
      it 'converts the range to a serializable hash' do
        hash = date_range.as_json
        expect(hash).to eq({
          start: start_date.strftime('%Y-%m-%d'),
          end: end_date.strftime('%Y-%m-%d')
        })
        expect(hash.to_json).to eq("{\"start\":\"2023-01-01\",\"end\":\"2023-12-31\"}")
      end
    end

    describe '.from_hash' do
      it 'deserializes from a serialized object' do
        serialized = date_range.to_json
        range = Flex::DateRange.from_hash(JSON.parse(serialized))
        expect(range).to eq(Flex::DateRange.new(start_date, end_date))
        expect(range.start).to eq(start_date)
        expect(range.end).to eq(end_date)
      end
    end

    describe '#==' do
      it 'returns true for ranges with same start and end values' do
        other_range = Flex::DateRange.new(start_date, end_date)
        expect(date_range).to eq(other_range)
      end

      it 'returns false for ranges with different values' do
        other_range = Flex::DateRange.new(start_date, Date.new(2023, 6, 1))
        expect(date_range).not_to eq(other_range)
      end
    end

    describe '.[]' do
      it 'creates a new value range class for the given value type' do
        number_range_class = described_class[Integer]
        range = number_range_class.new(1, 10)
        expect(range.class.value_class).to eq(Integer)
      end
    end
  end
end
