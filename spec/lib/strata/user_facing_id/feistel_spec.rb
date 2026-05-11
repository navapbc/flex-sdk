# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::UserFacingId::Feistel do
  describe "constants" do
    it "locks the default bit-width and round count" do
      # Changing either changes the permutation and breaks every encoded ID.
      expect(described_class::DEFAULT_BITS).to eq(30)
      expect(described_class::DEFAULT_ROUNDS).to eq(6)
      expect(described_class::DOMAIN_SIZE).to eq(1 << 30)
    end
  end

  describe ".permute and .invert" do
    it "are inverse operations for the 30-bit domain" do
      values = [
        0,
        1,
        12_345,
        1_000_000,
        described_class::DOMAIN_SIZE - 1
      ]

      values.each do |value|
        permuted = described_class.permute(value, key: Strata::UserFacingId::Codec::DEFAULT_KEY)

        expect(described_class.invert(permuted, key: Strata::UserFacingId::Codec::DEFAULT_KEY)).to eq(value)
      end
    end

    it "keeps values inside the 30-bit domain" do
      permuted = described_class.permute(12_345, key: Strata::UserFacingId::Codec::DEFAULT_KEY)

      expect(permuted).to be_between(0, described_class::DOMAIN_SIZE - 1)
    end

    it "is a bijection over a 10,000-value slice" do
      key = Strata::UserFacingId::Codec::DEFAULT_KEY
      permuted = (0...10_000).map { |value| described_class.permute(value, key: key) }

      expect(permuted.uniq.size).to eq(10_000)
      expect(permuted).to all(satisfy { |value| value.between?(0, described_class::DOMAIN_SIZE - 1) })

      permuted.each_with_index do |value, original|
        expect(described_class.invert(value, key: key)).to eq(original)
      end
    end

    it "produces different permutations under different keys" do
      under_default = described_class.permute(12_345, key: Strata::UserFacingId::Codec::DEFAULT_KEY)
      under_custom = described_class.permute(12_345, key: 0xdead_beef)

      expect(under_default).not_to eq(under_custom)
    end

    it "round-trips under a non-default round count" do
      key = Strata::UserFacingId::Codec::DEFAULT_KEY
      [ 2, 4, 8, 12 ].each do |rounds|
        permuted = described_class.permute(12_345, key: key, rounds: rounds)

        expect(described_class.invert(permuted, key: key, rounds: rounds)).to eq(12_345)
      end
    end

    it "round-trips under a non-default even bit count" do
      key = Strata::UserFacingId::Codec::DEFAULT_KEY
      [ 16, 20, 24, 32 ].each do |bits|
        max = (1 << bits) - 1
        [ 0, 1, max / 2, max ].each do |value|
          permuted = described_class.permute(value, key: key, bits: bits)

          expect(permuted).to be_between(0, max)
          expect(described_class.invert(permuted, key: key, bits: bits)).to eq(value)
        end
      end
    end
  end

  describe "domain and bit-width validation" do
    it "raises for odd bit counts" do
      expect do
        described_class.permute(0, key: Strata::UserFacingId::Codec::DEFAULT_KEY, bits: 15)
      end.to raise_error(ArgumentError)
    end

    it "raises for values at or above the domain size" do
      expect do
        described_class.permute(described_class::DOMAIN_SIZE, key: Strata::UserFacingId::Codec::DEFAULT_KEY)
      end.to raise_error(RangeError)
    end

    it "raises for negative values" do
      expect do
        described_class.permute(-1, key: Strata::UserFacingId::Codec::DEFAULT_KEY)
      end.to raise_error(RangeError)
    end
  end

  describe "key validation" do
    it "accepts positive integer keys" do
      expect { described_class.permute(0, key: 1) }.not_to raise_error
      expect { described_class.permute(0, key: 0xdead_beef) }.not_to raise_error
    end

    it "raises ArgumentError for zero" do
      expect { described_class.permute(0, key: 0) }.to raise_error(ArgumentError)
    end

    it "raises ArgumentError for negative integers" do
      expect { described_class.permute(0, key: -1) }.to raise_error(ArgumentError)
    end

    it "raises ArgumentError for non-integer keys" do
      [ nil, "0xdead", 1.5, :symbol ].each do |bad_key|
        expect { described_class.permute(0, key: bad_key) }.to raise_error(ArgumentError)
      end
    end

    it "applies the same validation to invert" do
      expect { described_class.invert(0, key: 0) }.to raise_error(ArgumentError)
      expect { described_class.invert(0, key: -1) }.to raise_error(ArgumentError)
      expect { described_class.invert(0, key: nil) }.to raise_error(ArgumentError)
    end
  end
end
