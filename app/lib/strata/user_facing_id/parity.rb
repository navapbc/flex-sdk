# frozen_string_literal: true

module Strata
  module UserFacingId
    # Calculates and validates the 4-bit checksum embedded in user-facing IDs.
    module Parity
      WEIGHTS = [ 1, 3, 7 ].freeze
      MASK = 0b1111

      module_function

      def calculate(value)
        chunks = [
          value % Alphabet::BASE,
          (value / Alphabet::BASE) % Alphabet::BASE,
          (value / (Alphabet::BASE**2)) % Alphabet::BASE
        ]

        chunks.zip(WEIGHTS).sum { |chunk, weight| chunk * weight } % 16
      end

      def append(value)
        (value << 4) | calculate(value)
      end

      def split(value)
        [ value >> 4, value & MASK ]
      end

      def valid?(value, parity)
        calculate(value) == parity
      end

      def validate!(value, parity)
        return true if valid?(value, parity)

        raise ParityError, "invalid user-facing ID parity"
      end
    end
  end
end
