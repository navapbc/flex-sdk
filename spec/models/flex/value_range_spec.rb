require 'rails_helper'

RSpec.describe Flex::ValueRange do
  let(:klass) do
    klass = described_class[value_class]
    klass.define_singleton_method(:name) { "#{value_class.name}Range" }
    klass
  end
  let(:range) { klass.new(start_value, end_value) }

  describe "ValueRange[USDate]" do
    let(:value_class) { Flex::USDate }
    let(:start_value) { Flex::USDate.new(2023, 1, 1) }
    let(:end_value) { Flex::USDate.new(2023, 12, 31) }

    describe 'validations' do
      it 'is valid with valid start and end dates' do
        expect(range).to be_valid
      end

      it 'is invalid when start date is after end date' do
        invalid_range = klass.new(end_value, start_value)
        expect(invalid_range).not_to be_valid
        expect(invalid_range.errors[:base]).to include("start date cannot be after end date")
      end

      it 'is valid when dates are blank' do
        range = klass.new(nil, nil)
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
          start: start_value.strftime('%Y-%m-%d'),
          end: end_value.strftime('%Y-%m-%d')
        })
        expect(hash.to_json).to eq("{\"start\":\"2023-01-01\",\"end\":\"2023-12-31\"}")
      end
    end

    describe '.from_hash' do
      it 'deserializes from a serialized object' do
        serialized = range.to_json
        range = klass.from_hash(JSON.parse(serialized))
        expect(range).to eq(klass.new(start_value, end_value))
      end

      it 'raises an error with nil' do
        expect { klass.from_hash(nil) }.to raise_error(TypeError)
      end

      it 'raises an error if hash is missing start key' do
        expect { klass.from_hash({ "end" => end_value }) }.to raise_error(ArgumentError)
      end

      it 'raises an error if hash is missing end key' do
        expect { klass.from_hash({ "start" => start_value }) }.to raise_error(ArgumentError)
      end
    end

    describe '#==' do
      it 'returns true for ranges with same start and end values' do
        other_range = klass.new(start_value, end_value)
        expect(range).to eq(other_range)
      end

      it 'returns false for ranges with different values' do
        expect(range).not_to eq(klass.new(start_value, Flex::USDate.new(2023, 6, 1)))
        expect(range).not_to eq(klass.new(Flex::USDate.new(2023, 1, 2), end_value))
      end
    end
  end

  describe "ValueRange[Integer]" do
    let(:value_class) { Integer }
    let(:start_value) { Faker::Number.within(range: -100..100) }
    let(:end_value) { start_value + Faker::Number.within(range: 1..100) }
    let(:range) { klass.new(start_value, end_value) }

    describe 'validations' do
      it 'is valid with valid start and end dates' do
        expect(range).to be_valid
      end

      it 'is invalid when start is greater than end' do
        invalid_range = klass.new(start_value, start_value - 1)
        expect(invalid_range).not_to be_valid
        expect(invalid_range.errors[:base]).to include("start cannot be greater than end")
      end

      it 'is valid when start and end is blank' do
        range = klass.new(nil, nil)
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
          start: start_value,
          end: end_value
        })
        expect(hash.to_json).to eq("{\"start\":#{start_value},\"end\":#{end_value}}")
      end
    end

    describe '.from_hash' do
      it 'deserializes from a serialized object' do
        serialized = range.to_json
        range = klass.from_hash(JSON.parse(serialized))
        expect(range).to eq(klass.new(start_value, end_value))
      end

      it 'raises an error with nil' do
        expect { klass.from_hash(nil) }.to raise_error(TypeError)
      end

      it 'raises an error if hash is missing start or end key' do
        expect { klass.from_hash({ "end" => end_value }) }.to raise_error(ArgumentError)
        expect { klass.from_hash({ "start" => start_value }) }.to raise_error(ArgumentError)
      end

      it 'does not raise an error if start or end is 0' do
        expect { klass.from_hash({ "start" => 0, "end" => end_value }) }.not_to raise_error
        expect { klass.from_hash({ "start" => start_value, "end" => 0 }) }.not_to raise_error
      end
    end

    describe '#==' do
      it 'returns true for ranges with same start and end values' do
        other_range = klass.new(start_value, end_value)
        expect(range).to eq(other_range)
      end

      it 'returns false for ranges with different values' do
        expect(range).not_to eq(klass.new(start_value, end_value + 1))
        expect(range).not_to eq(klass.new(start_value + 1, end_value))
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
        invalid_range = klass.new("banana", "apple")
        expect(invalid_range).not_to be_valid
        expect(invalid_range.errors[:base]).to include("start must come before end alphabetically")
      end

      it 'is valid when start and end is blank' do
        range = klass.new(nil, nil)
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
          start: start_value,
          end: end_value
        })
        expect(hash.to_json).to eq("{\"start\":\"#{start_value}\",\"end\":\"#{end_value}\"}")
      end
    end

    describe '.from_hash' do
      it 'deserializes from a serialized object' do
        serialized = range.to_json
        range = klass.from_hash(JSON.parse(serialized))
        expect(range).to eq(klass.new(start_value, end_value))
      end

      it 'raises an error with nil' do
        expect { klass.from_hash(nil) }.to raise_error(TypeError)
      end

      it 'raises an error if hash is missing start or end key' do
        expect { klass.from_hash({ "end" => end_value }) }.to raise_error(ArgumentError)
        expect { klass.from_hash({ "start" => start_value }) }.to raise_error(ArgumentError)
      end

      it 'does not raise an error if start or end is an empty string' do
        expect { klass.from_hash({ "start" => "", "end" => end_value }) }.not_to raise_error
        expect { klass.from_hash({ "start" => start_value, "end" => "" }) }.not_to raise_error
      end
    end

    describe '#==' do
      it 'returns true for ranges with same start and end values' do
        other_range = klass.new(start_value, end_value)
        expect(range).to eq(other_range)
      end

      it 'returns false for ranges with different values' do
        expect(range).not_to eq(klass.new(start_value, "orange"))
        expect(range).not_to eq(klass.new("apple", end_value))
      end
    end
  end

  describe ".[]" do
    it 'memoizes the value range class for a given value class' do
      expect(Flex::DateRange).to be(described_class[Flex::USDate])
      [ Date, Integer, String ].each do |value_class|
        expect(described_class[value_class]).to be(described_class[value_class]) # rubocop:disable RSpec/IdenticalEqualityAssertion
      end
    end
  end
end
