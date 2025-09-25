require 'rails_helper'

RSpec.describe Strata::Name do
  let(:first) { "Jane" }
  let(:middle) { "Adams" }
  let(:last) { "Doe" }
  let(:name) { described_class.new(first:, middle:, last:) }
  let(:same_name) { described_class.new(first:, middle:, last:) }
  let(:different_name) { described_class.new(first: "John", middle:, last:) }

  describe '#initialize' do
    it 'sets first, middle, and last names' do
      expect(name.first).to eq("Jane")
      expect(name.middle).to eq("Adams")
      expect(name.last).to eq("Doe")
    end
  end

  describe '#<=>' do
    it 'returns 0 for equal names' do
      expect(name <=> same_name).to eq(0)
    end

    it 'returns -1 for names that sort before' do
      expect(name <=> different_name).to eq(-1)
    end

    it 'returns 1 for names that sort after' do
      expect(different_name <=> name).to eq(1)
    end
  end

  describe '#persisted?' do
    it 'returns false' do
      expect(name).not_to be_persisted
    end
  end

  describe '#full_name' do
    it 'returns properly formatted full name' do
      expect(name.full_name).to eq('Jane Adams Doe')
    end
  end

  describe '#blank?' do
    [
      [ 'all nil components', nil, nil, nil, true ],
      [ 'all empty string components', '', '', '', true ],
      [ 'all whitespace components', '  ', '  ', '  ', true ],
      [ 'mixed nil and empty', nil, '', nil, true ],
      [ 'mixed nil and whitespace', nil, '  ', '', true ],
      [ 'first name only', 'John', nil, nil, false ],
      [ 'middle name only', nil, 'A', nil, false ],
      [ 'last name only', nil, nil, 'Doe', false ],
      [ 'first and last names', 'John', nil, 'Doe', false ],
      [ 'all names present', 'John', 'A', 'Doe', false ],
      [ 'first name with whitespace only middle/last', 'John', '  ', '', false ]
    ].each do |description, first, middle, last, expected|
      it "returns #{expected} when #{description}" do
        name = described_class.new(first:, middle:, last:)
        expect(name.blank?).to eq(expected)
      end
    end
  end

  describe '#empty?' do
    [
      [ 'all nil components', nil, nil, nil, true ],
      [ 'all empty string components', '', '', '', true ],
      [ 'mixed nil and empty', nil, '', nil, true ],
      [ 'first name only', 'John', nil, nil, false ],
      [ 'middle name only', nil, 'A', nil, false ],
      [ 'last name only', nil, nil, 'Doe', false ],
      [ 'first and last names', 'John', nil, 'Doe', false ],
      [ 'all names present', 'John', 'A', 'Doe', false ],
      [ 'whitespace components', '  ', '  ', '  ', false ]
    ].each do |description, first, middle, last, expected|
      it "returns #{expected} when #{description}" do
        name = described_class.new(first:, middle:, last:)
        expect(name.empty?).to eq(expected)
      end
    end
  end

  describe '#present?' do
    [
      [ 'all nil components', nil, nil, nil, false ],
      [ 'all empty string components', '', '', '', false ],
      [ 'all whitespace components', '  ', '  ', '  ', false ],
      [ 'mixed nil and empty', nil, '', nil, false ],
      [ 'mixed nil and whitespace', nil, '  ', '', false ],
      [ 'first name only', 'John', nil, nil, true ],
      [ 'middle name only', nil, 'A', nil, true ],
      [ 'last name only', nil, nil, 'Doe', true ],
      [ 'first and last names', 'John', nil, 'Doe', true ],
      [ 'all names present', 'John', 'A', 'Doe', true ],
      [ 'first name with whitespace only middle/last', 'John', '  ', '', true ]
    ].each do |description, first, middle, last, expected|
      it "returns #{expected} when #{description}" do
        name = described_class.new(first:, middle:, last:)
        expect(name.present?).to eq(expected)
      end
    end
  end

  describe '#to_s' do
    [
      [ 'returns full name with all components', 'John', 'A', 'Smith', 'John A Smith' ],
      [ 'handles missing middle name', 'John', nil, 'Smith', 'John Smith' ],
      [ 'handles missing components', nil, 'A', 'Smith', 'A Smith' ],
      [ 'returns empty string for all nil components', nil, nil, nil, '' ]
    ].each do |description, first, middle, last, expected|
      it description do
        name = described_class.new(first:, middle:, last:)
        expect(name.to_s).to eq(expected)
      end
    end
  end
end
