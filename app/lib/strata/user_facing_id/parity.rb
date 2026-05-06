# frozen_string_literal: true

module Strata
  module UserFacingId
    # Calculates and validates the 4-bit checksum embedded in user-facing IDs.
    module Parity
      # Different weights make transposed or changed segments more likely to fail validation.
      WEIGHTS = [ 1, 3, 7 ].freeze

      # Four parity bits can represent checksums from 0 through 15.
      MASK = 0b1111

      module_function

      def calculate(value)
        # Work in the same base as the visible LNN segments.
        chunks = [
          value % Alphabet::BASE,
          (value / Alphabet::BASE) % Alphabet::BASE,
          (value / (Alphabet::BASE**2)) % Alphabet::BASE
        ]

        chunks.zip(WEIGHTS).sum { |chunk, weight| chunk * weight } % 16
      end

      def append(value)
        # Shift data left, then use the low four bits for the checksum.
        (value << 4) | calculate(value)
      end

      def split(value)
        # Undo append: data lives above the low four parity bits.
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
