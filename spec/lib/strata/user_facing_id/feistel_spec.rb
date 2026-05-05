# frozen_string_literal: true

require "spec_helper"
require_relative "../../../../app/lib/strata/user_facing_id/error"
require_relative "../../../../app/lib/strata/user_facing_id/format_error"
require_relative "../../../../app/lib/strata/user_facing_id/parity_error"
require_relative "../../../../app/lib/strata/user_facing_id/alphabet"
require_relative "../../../../app/lib/strata/user_facing_id/feistel"
require_relative "../../../../app/lib/strata/user_facing_id/parity"
require_relative "../../../../app/lib/strata/user_facing_id/codec"

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
end
