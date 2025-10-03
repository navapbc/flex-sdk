# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Strata::TaxId do
  describe '#initialize' do
    it 'strips non-numeric characters from the input' do
      tax_id = described_class.new('123-45-6789')
      expect(tax_id).to eq('123456789')
    end

    it 'converts input to string' do
      tax_id = described_class.new(123456789)
      expect(tax_id).to eq('123456789')
    end
  end

  describe '#formatted' do
    context 'when tax ID has 9 digits' do
      it 'returns the tax ID in XXX-XX-XXXX format' do
        tax_id = described_class.new('123456789')
        expect(tax_id.formatted).to eq('123-45-6789')
      end
    end

    context 'when tax ID does not have 9 digits' do
      it 'returns the original string' do
        tax_id = described_class.new('12345')
        expect(tax_id.formatted).to eq('12345')
      end
    end
  end

  describe '#<=>' do
    let(:small_tax_id) { described_class.new(Faker::Number.between(from: 100000000, to: 333333333)) }
    let(:medium_tax_id) { described_class.new(Faker::Number.between(from: 334444444, to: 666666666)) }
    let(:large_tax_id) { described_class.new(Faker::Number.between(from: 667777777, to: 999999999)) }
    let(:same_small_tax_id) { described_class.new(small_tax_id.to_s) }

    it 'compares with another TaxId object - less than' do
      expect(small_tax_id < medium_tax_id).to be true
      expect(medium_tax_id < large_tax_id).to be true
      expect(large_tax_id < small_tax_id).to be false
    end

    it 'compares with another TaxId object - greater than' do
      expect(large_tax_id > medium_tax_id).to be true
      expect(medium_tax_id > small_tax_id).to be true
      expect(small_tax_id > large_tax_id).to be false
    end

    it 'compares with another TaxId object - equal to' do
      expect(small_tax_id == same_small_tax_id).to be true
      expect(small_tax_id == medium_tax_id).to be false
    end

    it 'compares with a string - equal to' do
      expect(small_tax_id == small_tax_id.to_s).to be true
      expect(small_tax_id == large_tax_id.to_s).to be false
    end

    it 'compares with a string - less than' do
      expect(small_tax_id < large_tax_id.to_s).to be true
      expect(large_tax_id < small_tax_id.to_s).to be false
    end

    it 'compares with a string - greater than' do
      expect(large_tax_id > small_tax_id.to_s).to be true
      expect(small_tax_id > large_tax_id.to_s).to be false
    end
  end

  # Tests for inherited String methods
  describe 'String method inheritance' do
    let(:tax_id) { described_class.new('123456789') }
    let(:empty_tax_id) { described_class.new('') }
    let(:whitespace_tax_id) { described_class.new('   ') }

    describe '#blank?' do
      it 'returns true for an empty tax ID' do
        expect(empty_tax_id.blank?).to be true
      end

      it 'returns true for a whitespace-only tax ID' do
        expect(whitespace_tax_id.blank?).to be true
      end

      it 'returns false for a non-empty tax ID' do
        expect(tax_id.blank?).to be false
      end
    end

    describe '#empty?' do
      it 'returns true for an empty tax ID' do
        expect(empty_tax_id.empty?).to be true
      end

      it 'returns true for a whitespace-only tax ID' do
        expect(whitespace_tax_id.empty?).to be true
      end

      it 'returns false for a non-empty tax ID' do
        expect(tax_id.empty?).to be false
      end
    end

    describe '#present?' do
      it 'returns false for an empty tax ID' do
        expect(empty_tax_id.present?).to be false
      end

      it 'returns false for a whitespace-only tax ID' do
        expect(whitespace_tax_id.present?).to be false
      end

      it 'returns true for a non-empty tax ID' do
        expect(tax_id.present?).to be true
      end
    end

    describe '#to_s' do
      it 'returns the raw tax ID string' do
        expect(tax_id.to_s).to eq('123456789')
      end

      it 'returns empty string for empty tax ID' do
        expect(empty_tax_id.to_s).to eq('')
      end
    end
  end
end
