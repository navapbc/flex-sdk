# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::UserFacingId::Feistel do
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
