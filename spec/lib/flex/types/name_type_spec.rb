require 'rails_helper'

RSpec.describe Flex::Types::NameType do
  let(:type) { described_class.new }

  describe '#cast' do
    context 'when value is a Flex::Name object' do
      it 'returns the value unchanged' do
        name = Flex::Name.new(first: 'John', middle: 'Q', last: 'Doe')
        result = type.cast(name)
        expect(result).to eq(name)
        expect(result).to be_a(Flex::Name)
      end
    end

    context 'when value is a hash with symbol keys' do
      it 'creates a Flex::Name object' do
        hash = { first: 'Jane', middle: 'M', last: 'Smith' }
        result = type.cast(hash)
        expect(result).to be_a(Flex::Name)
        expect(result.first).to eq('Jane')
        expect(result.middle).to eq('M')
        expect(result.last).to eq('Smith')
      end

      it 'handles missing middle name' do
        hash = { first: 'Bob', last: 'Johnson' }
        result = type.cast(hash)
        expect(result).to be_a(Flex::Name)
        expect(result.first).to eq('Bob')
        expect(result.middle).to be_nil
        expect(result.last).to eq('Johnson')
      end
    end

    context 'when value is a hash with string keys' do
      it 'creates a Flex::Name object' do
        hash = { "first" => 'Alice', "middle" => 'B', "last" => 'Wilson' }
        result = type.cast(hash)
        expect(result).to be_a(Flex::Name)
        expect(result.first).to eq('Alice')
        expect(result.middle).to eq('B')
        expect(result.last).to eq('Wilson')
      end

      it 'prefers symbol keys over string keys when both exist' do
        hash = { first: 'Symbol', "first" => 'String', last: 'Name' }
        result = type.cast(hash)
        expect(result.first).to eq('Symbol')
        expect(result.last).to eq('Name')
      end
    end

    context 'when value is nil' do
      it 'returns nil' do
        result = type.cast(nil)
        expect(result).to be_nil
      end
    end

    context 'when value is a string' do
      it 'creates a Flex::Name with only first name' do
        result = type.cast('SingleName')
        expect(result).to be_a(Flex::Name)
        expect(result.first).to eq('SingleName')
        expect(result.middle).to be_nil
        expect(result.last).to be_nil
      end
    end

    context 'when value is a number' do
      it 'converts to string and creates Flex::Name with first name' do
        result = type.cast(123)
        expect(result).to be_a(Flex::Name)
        expect(result.first).to eq('123')
        expect(result.middle).to be_nil
        expect(result.last).to be_nil
      end
    end

    context 'when value is an empty string' do
      it 'creates a Flex::Name with empty first name' do
        result = type.cast('')
        expect(result).to be_a(Flex::Name)
        expect(result.first).to eq('')
        expect(result.middle).to be_nil
        expect(result.last).to be_nil
      end
    end
  end

  describe '#serialize' do
    context 'when value is nil' do
      it 'returns nil' do
        result = type.serialize(nil)
        expect(result).to be_nil
      end
    end

    context 'when value is already a string' do
      it 'returns the string unchanged' do
        result = type.serialize('already a string')
        expect(result).to eq('already a string')
      end
    end

    context 'when value is a Flex::Name object' do
      it 'converts to string using to_s method' do
        name = Flex::Name.new(first: 'John', middle: 'Q', last: 'Doe')
        result = type.serialize(name)
        expect(result).to eq(name.to_s)
      end
    end

    context 'when value is another object' do
      it 'converts to string using to_s method' do
        result = type.serialize(123)
        expect(result).to eq('123')
      end
    end
  end

  describe '#deserialize' do
    context 'when value is nil' do
      it 'returns nil' do
        result = type.deserialize(nil)
        expect(result).to be_nil
      end
    end

    context 'when value is a string' do
      it 'creates a Flex::Name with first name only' do
        result = type.deserialize('John Doe')
        expect(result).to be_a(Flex::Name)
        expect(result.first).to eq('John Doe')
        expect(result.middle).to be_nil
        expect(result.last).to be_nil
      end
    end

    context 'when value is a JSON string representing a hash' do
      it 'parses and creates a Flex::Name object' do
        json_string = '{"first":"Jane","middle":"M","last":"Smith"}'
        result = type.deserialize(json_string)
        expect(result).to be_a(Flex::Name)
        expect(result.first).to eq('Jane')
        expect(result.middle).to eq('M')
        expect(result.last).to eq('Smith')
      end

      it 'handles malformed JSON gracefully' do
        malformed_json = '{"first":"Jane"'
        result = type.deserialize(malformed_json)
        expect(result).to be_a(Flex::Name)
        expect(result.first).to eq('{"first":"Jane"')
      end
    end
  end
end
