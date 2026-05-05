# frozen_string_literal: true

require "spec_helper"
require_relative "../../../../app/lib/strata/user_facing_id/error"
require_relative "../../../../app/lib/strata/user_facing_id/format_error"
require_relative "../../../../app/lib/strata/user_facing_id/parity_error"
require_relative "../../../../app/lib/strata/user_facing_id/alphabet"
require_relative "../../../../app/lib/strata/user_facing_id/feistel"
require_relative "../../../../app/lib/strata/user_facing_id/parity"
require_relative "../../../../app/lib/strata/user_facing_id/codec"

RSpec.describe Strata::UserFacingId::Codec do
  describe ".encode and .decode" do
    it "round-trips sequence values" do
      [
        0,
        1,
        12_345,
        1_000_000,
        described_class::MAX_VALUE
      ].each do |value|
        encoded = described_class.encode(value, prefix: "C")

        expect(described_class.decode(encoded, prefix: "C")).to eq(value)
      end
    end

    it "uses a three-segment user-facing format" do
      encoded = described_class.encode(12_345, prefix: "C")

      expect(encoded).to match(/\AC-[A-HJ-Z]\d{2}-[A-HJ-Z]\d{2}-[A-HJ-Z]\d{2}\z/)
    end

    it "is deterministic" do
      encoded = described_class.encode(12_345, prefix: "C")

      expect(described_class.encode(12_345, prefix: "C")).to eq(encoded)
    end

    it "does not collide across a sample of the domain" do
      encoded_values = (0...10_000).map { |value| described_class.encode(value, prefix: "C") }

      expect(encoded_values.uniq.size).to eq(encoded_values.size)
    end

    it "raises for invalid format" do
      expect do
        described_class.decode("C-Y01-I33-N91", prefix: "C")
      end.to raise_error(Strata::UserFacingId::FormatError)
    end

    it "raises for a prefix mismatch" do
      encoded = described_class.encode(12_345, prefix: "C")

      expect do
        described_class.decode(encoded, prefix: "D")
      end.to raise_error(Strata::UserFacingId::FormatError)
    end

    it "raises for a parity mismatch" do
      encoded = described_class.encode(12_345, prefix: "C")
      tampered = encoded.sub(/\d\z/) { |digit| ((digit.to_i + 1) % 10).to_s }

      expect do
        described_class.decode(tampered, prefix: "C")
      end.to raise_error(Strata::UserFacingId::ParityError)
    end

    it "raises when the value is outside the available capacity" do
      expect do
        described_class.encode(described_class::MAX_VALUE + 1, prefix: "C")
      end.to raise_error(RangeError)
    end
  end
end
