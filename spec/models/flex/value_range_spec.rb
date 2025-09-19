require 'rails_helper'

RSpec.describe Strata::ValueRange do
  let(:klass) do
    klass = described_class[value_class]
    klass.define_singleton_method(:name) { "#{value_class.name}Range" }
    klass
  end
  let(:range) { klass.new(start: start_value, end: end_value) }

  describe "ValueRange[USDate]" do
    let(:value_class) { Strata::USDate }
    let(:start_value) { Strata::USDate.new(2023, 1, 1) }
    let(:end_value) { Strata::USDate.new(2023, 12, 31) }

    describe 'validations' do
      it 'is valid with valid start and end dates' do
        expect(range).to be_valid
      end

      it 'is invalid when start date is after end date' do
        invalid_range = klass.new(start: end_value, end: start_value)
        expect(invalid_range).not_to be_valid
        expect(invalid_range.errors[:base]).to include("start date cannot be after end date")
      end

      it 'is valid when dates are blank' do
        range = klass.new
        expect(range).to be_valid
      end
    end

    describe '#include?' do
      it 'returns true for a date within the range' do
        middle_date = Date.new(2023, 6, 1)
        expect(range.include?(middle_date)).to be true
      end

      it 'returns true for boundary dates' do
        expect(range.include?(start_value)).to be true
        expect(range.include?(end_value)).to be true
      end

      it 'returns false for dates outside the range' do
        before_date = Date.new(2022, 12, 31)
        after_date = Date.new(2024, 1, 1)
        expect(range.include?(before_date)).to be false
        expect(range.include?(after_date)).to be false
      end
    end

    describe '#as_json' do
      it 'converts the range to a serializable hash' do
        hash = range.as_json
        expect(hash).to eq({
          "start" => start_value.strftime('%Y-%m-%d'),
          "end" => end_value.strftime('%Y-%m-%d')
        })
        expect(hash.to_json).to eq("{\"start\":\"2023-01-01\",\"end\":\"2023-12-31\"}")
      end
    end

    describe 'deserialization' do
      it 'from a serialized object' do
        serialized = range.to_json
        range = klass.new(JSON.parse(serialized))
        expect(range).to eq(klass.new(start: start_value, end: end_value))
      end
    end

    describe '#==' do
      it 'returns true for ranges with same start and end values' do
        other_range = klass.new(start: start_value, end: end_value)
        expect(range).to eq(other_range)
      end

      it 'returns false for ranges with different values' do
        expect(range).not_to eq(klass.new(start: start_value, end: Strata::USDate.new(2023, 6, 1)))
        expect(range).not_to eq(klass.new(start: Strata::USDate.new(2023, 1, 2), end: end_value))
      end
    end
  end

  describe "ValueRange[Integer]" do
    let(:value_class) { Integer }
    let(:start_value) { Faker::Number.within(range: -100..100) }
    let(:end_value) { start_value + Faker::Number.within(range: 1..100) }

    describe 'validations' do
      it 'is valid with valid start and end dates' do
        expect(range).to be_valid
      end

      it 'is invalid when start is greater than end' do
        invalid_range = klass.new(start: start_value, end: start_value - 1)
        expect(invalid_range).not_to be_valid
        expect(invalid_range.errors[:base]).to include("start cannot be greater than end")
      end

      it 'is valid when start and end is blank' do
        range = klass.new
        expect(range).to be_valid
      end
    end

    describe '#include?' do
      it 'returns true for a number within the range' do
        value = (start_value + end_value) / 2
        expect(range.include?(value)).to be true
      end

      it 'returns true for boundary values' do
        expect(range.include?(start_value)).to be true
        expect(range.include?(end_value)).to be true
      end

      it 'returns false for values outside the range' do
        expect(range.include?(start_value - 1)).to be false
        expect(range.include?(end_value + 1)).to be false
      end
    end

    describe '#as_json' do
      it 'converts the range to a serializable hash' do
        hash = range.as_json
        expect(hash).to eq({
          "start" => start_value,
          "end" => end_value
        })
        expect(hash.to_json).to eq("{\"start\":#{start_value},\"end\":#{end_value}}")
      end
    end

    describe 'deserialization' do
      it 'from a serialized object' do
        serialized = range.to_json
        range = klass.new(JSON.parse(serialized))
        expect(range).to eq(klass.new(start: start_value, end: end_value))
      end
    end

    describe '#==' do
      it 'returns true for ranges with same start and end values' do
        other_range = klass.new(start: start_value, end: end_value)
        expect(range).to eq(other_range)
      end

      it 'returns false for ranges with different values' do
        expect(range).not_to eq(klass.new(start: start_value, end: end_value + 1))
        expect(range).not_to eq(klass.new(start: start_value + 1, end: end_value))
      end
    end
  end

  describe "ValueRange[String]" do
    let(:value_class) { String }
    let(:start_value) { "banana" }
    let(:end_value) { "pineapple" }

    describe 'validations' do
      it 'is valid with valid start and end dates' do
        expect(range).to be_valid
      end

      it 'is invalid when start is greater than end' do
        invalid_range = klass.new(start: "banana", end: "apple")
        expect(invalid_range).not_to be_valid
        expect(invalid_range.errors[:base]).to include("start must come before end alphabetically")
      end

      it 'is valid when start and end is blank' do
        range = klass.new
        expect(range).to be_valid
      end
    end

    describe '#include?' do
      it 'returns true for a number within the range' do
        expect(range.include?("orange")).to be true
      end

      it 'returns true for boundary values' do
        expect(range.include?(start_value)).to be true
        expect(range.include?(end_value)).to be true
      end

      it 'returns false for values outside the range' do
        expect(range.include?("apple")).to be false
        expect(range.include?("strawberry")).to be false
      end
    end

    describe '#as_json' do
      it 'converts the range to a serializable hash' do
        hash = range.as_json
        expect(hash).to eq({
          "start" => start_value,
          "end" => end_value
        })
        expect(hash.to_json).to eq("{\"start\":\"#{start_value}\",\"end\":\"#{end_value}\"}")
      end
    end

    describe 'deserialization' do
      it 'from a serialized object' do
        serialized = range.to_json
        range = klass.new(JSON.parse(serialized))
        expect(range).to eq(klass.new(start: start_value, end: end_value))
      end
    end

    describe '#==' do
      it 'returns true for ranges with same start and end values' do
        other_range = klass.new(start: start_value, end: end_value)
        expect(range).to eq(other_range)
      end

      it 'returns false for ranges with different values' do
        expect(range).not_to eq(klass.new(start: start_value, end: "orange"))
        expect(range).not_to eq(klass.new(start: "apple", end: end_value))
      end
    end
  end

  describe "ValueRange[YearMonth]" do
    let(:value_class) { Strata::YearMonth }
    let(:start_value) { Strata::YearMonth.new(year: 2023, month: 6) }
    let(:end_value) { Strata::YearMonth.new(year: 2023, month: 12) }

    describe 'validations' do
      it 'is valid with valid start and end months' do
        expect(range).to be_valid
      end

      it 'is invalid when start month is after end month' do
        invalid_range = klass.new(start: Strata::YearMonth.new(year: 2023, month: 12), end: Strata::YearMonth.new(year: 2023, month: 6))
        expect(invalid_range).not_to be_valid
        expect(invalid_range.errors[:base]).to include("start cannot be after end")
      end

      it 'is valid when months are blank' do
        range = klass.new
        expect(range).to be_valid
      end
    end

    describe '#include?' do
      it 'returns true for a month within the range' do
        middle_month = Strata::YearMonth.new(year: 2023, month: 9)
        expect(range.include?(middle_month)).to be true
      end

      it 'returns true for boundary months' do
        expect(range.include?(start_value)).to be true
        expect(range.include?(end_value)).to be true
      end

      it 'returns false for months outside the range' do
        before_month = Strata::YearMonth.new(year: 2023, month: 1)
        after_month = Strata::YearMonth.new(year: 2024, month: 1)
        expect(range.include?(before_month)).to be false
        expect(range.include?(after_month)).to be false
      end
    end

    describe '#as_json' do
      it 'converts the range to a serializable hash' do
        hash = range.as_json
        expect(hash).to eq({
          "start" => { "year" => 2023, "month" => 6 },
          "end" => { "year" => 2023, "month" => 12 }
        })
      end
    end

    describe 'deserialization' do
      it 'from a serialized object' do
        serialized = range.to_json
        range = klass.new(JSON.parse(serialized))
        expect(range).to eq(klass.new(start: start_value, end: end_value))
      end
    end

    describe '#==' do
      it 'returns true for ranges with same start and end values' do
        other_range = klass.new(start: start_value, end: end_value)
        expect(range).to eq(other_range)
      end

      it 'returns false for ranges with different values' do
        expect(range).not_to eq(klass.new(start: start_value, end: Strata::YearMonth.new(year: 2023, month: 9)))
        expect(range).not_to eq(klass.new(start: Strata::YearMonth.new(year: 2023, month: 7), end: end_value))
      end
    end
  end

  describe "ValueRange[YearQuarter]" do
    let(:value_class) { Strata::YearQuarter }
    let(:start_value) { Strata::YearQuarter.new(year: 2023, quarter: 1) }
    let(:end_value) { Strata::YearQuarter.new(year: 2023, quarter: 4) }

    describe 'validations' do
      it 'is valid with valid start and end quarters' do
        expect(range).to be_valid
      end

      it 'is invalid when start quarter is after end quarter' do
        invalid_range = klass.new(start: Strata::YearQuarter.new(year: 2023, quarter: 4), end: Strata::YearQuarter.new(year: 2023, quarter: 1))
        expect(invalid_range).not_to be_valid
        expect(invalid_range.errors[:base]).to include("start cannot be after end")
      end

      it 'is valid when quarters are blank' do
        range = klass.new
        expect(range).to be_valid
      end
    end

    describe '#include?' do
      it 'returns true for a quarter within the range' do
        middle_quarter = Strata::YearQuarter.new(year: 2023, quarter: 2)
        expect(range.include?(middle_quarter)).to be true
      end

      it 'returns true for boundary quarters' do
        expect(range.include?(start_value)).to be true
        expect(range.include?(end_value)).to be true
      end

      it 'returns false for quarters outside the range' do
        before_quarter = Strata::YearQuarter.new(year: 2022, quarter: 4)
        after_quarter = Strata::YearQuarter.new(year: 2024, quarter: 1)
        expect(range.include?(before_quarter)).to be false
        expect(range.include?(after_quarter)).to be false
      end
    end

    describe '#as_json' do
      it 'converts the range to a serializable hash' do
        hash = range.as_json
        expect(hash).to eq({
          "start" => { "year" => 2023, "quarter" => 1 },
          "end" => { "year" => 2023, "quarter" => 4 }
        })
      end
    end

    describe 'deserialization' do
      it 'from a serialized object' do
        serialized = range.to_json
        range = klass.new(JSON.parse(serialized))
        expect(range).to eq(klass.new(start: start_value, end: end_value))
      end
    end

    describe '#==' do
      it 'returns true for ranges with same start and end values' do
        other_range = klass.new(start: start_value, end: end_value)
        expect(range).to eq(other_range)
      end

      it 'returns false for ranges with different values' do
        expect(range).not_to eq(klass.new(start: start_value, end: Strata::YearQuarter.new(year: 2023, quarter: 3)))
        expect(range).not_to eq(klass.new(start: Strata::YearQuarter.new(year: 2023, quarter: 2), end: end_value))
      end
    end
  end

  describe ".[]" do
    it 'memoizes the value range class for a given value class' do
      expect(Flex::DateRange).to be(described_class[Flex::USDate])
      [ Flex::USDate, Integer, String ].each do |value_class|
        expect(described_class[value_class]).to be(described_class[value_class]) # rubocop:disable RSpec/IdenticalEqualityAssertion
      end
    end

    it 'raises ArgumentError when using Date as value class' do
      expect { described_class[Date] }.to raise_error(
        ArgumentError,
        "Use Flex::ValueRange[Flex::USDate] or Flex::DateRange instead of Flex::ValueRange[Date]"
      )
    end
  end
end
