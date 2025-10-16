# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Strata::Name do
  let(:first) { "Jane" }
  let(:middle) { "Adams" }
  let(:last) { "Doe" }
  let(:suffix) { "Jr." }
  let(:name) { described_class.new(first:, middle:, last:, suffix:) }
  let(:same_name) { described_class.new(first:, middle:, last:, suffix:) }
  let(:different_name) { described_class.new(first: "John", middle:, last:, suffix:) }

  describe '#initialize' do
    it 'sets first, middle, last, and suffix names' do
      expect(name.first).to eq("Jane")
      expect(name.middle).to eq("Adams")
      expect(name.last).to eq("Doe")
      expect(name.suffix).to eq("Jr.")
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
      expect(name.full_name).to eq('Jane Adams Doe Jr.')
    end
  end

  describe '#blank?' do
    [
      [ 'all nil components', nil, nil, nil, nil, true ],
      [ 'all empty string components', '', '', '', '', true ],
      [ 'all whitespace components', '  ', '  ', '  ', '  ', true ],
      [ 'mixed nil and empty', nil, '', nil, '', true ],
      [ 'mixed nil and whitespace', nil, '  ', '', '  ', true ],
      [ 'first name only', 'John', nil, nil, nil, false ],
      [ 'middle name only', nil, 'A', nil, nil, false ],
      [ 'last name only', nil, nil, 'Doe', nil, false ],
      [ 'suffix only', nil, nil, nil, 'Jr.', false ],
      [ 'first and last names', 'John', nil, 'Doe', nil, false ],
      [ 'all names present', 'John', 'A', 'Doe', 'Jr.', false ],
      [ 'first name with whitespace only middle/last/suffix', 'John', '  ', '', '  ', false ]
    ].each do |description, first, middle, last, suffix, expected|
      it "returns #{expected} when #{description}" do
        name = described_class.new(first:, middle:, last:, suffix:)
        expect(name.blank?).to eq(expected)
      end
    end
  end

  describe '#empty?' do
    [
      [ 'all nil components', nil, nil, nil, nil, true ],
      [ 'all empty string components', '', '', '', '', true ],
      [ 'mixed nil and empty', nil, '', nil, '', true ],
      [ 'first name only', 'John', nil, nil, nil, false ],
      [ 'middle name only', nil, 'A', nil, nil, false ],
      [ 'last name only', nil, nil, 'Doe', nil, false ],
      [ 'suffix only', nil, nil, nil, 'Jr.', false ],
      [ 'first and last names', 'John', nil, 'Doe', nil, false ],
      [ 'all names present', 'John', 'A', 'Doe', 'Jr.', false ],
      [ 'whitespace components', '  ', '  ', '  ', '  ', false ]
    ].each do |description, first, middle, last, suffix, expected|
      it "returns #{expected} when #{description}" do
        name = described_class.new(first:, middle:, last:, suffix:)
        expect(name.empty?).to eq(expected)
      end
    end
  end

  describe '#present?' do
    [
      [ 'all nil components', nil, nil, nil, nil, false ],
      [ 'all empty string components', '', '', '', '', false ],
      [ 'all whitespace components', '  ', '  ', '  ', '  ', false ],
      [ 'mixed nil and empty', nil, '', nil, '', false ],
      [ 'mixed nil and whitespace', nil, '  ', '', '  ', false ],
      [ 'first name only', 'John', nil, nil, nil, true ],
      [ 'middle name only', nil, 'A', nil, nil, true ],
      [ 'last name only', nil, nil, 'Doe', nil, true ],
      [ 'suffix only', nil, nil, nil, 'Jr.', true ],
      [ 'first and last names', 'John', nil, 'Doe', nil, true ],
      [ 'all names present', 'John', 'A', 'Doe', 'Jr.', true ],
      [ 'first name with whitespace only middle/last/suffix', 'John', '  ', '', '  ', true ]
    ].each do |description, first, middle, last, suffix, expected|
      it "returns #{expected} when #{description}" do
        name = described_class.new(first:, middle:, last:, suffix:)
        expect(name.present?).to eq(expected)
      end
    end
  end

  describe '#to_s' do
    [
      [ 'returns full name with all components', 'John', 'A', 'Smith', 'Jr.', 'John A Smith Jr.' ],
      [ 'handles missing middle name', 'John', nil, 'Smith', 'Jr.', 'John Smith Jr.' ],
      [ 'handles missing middle name and suffix', 'John', nil, 'Smith', nil, 'John Smith' ],
      [ 'handles missing suffix', 'John', 'A', 'Smith', nil, 'John A Smith' ],
      [ 'handles missing components', nil, 'A', 'Smith', 'Jr.', 'A Smith Jr.' ],
      [ 'returns empty string for all nil components', nil, nil, nil, nil, '' ]
    ].each do |description, first, middle, last, suffix, expected|
      it description do
        name = described_class.new(first:, middle:, last:, suffix:)
        expect(name.to_s).to eq(expected)
      end
    end
  end
end
