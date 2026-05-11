# frozen_string_literal: true

module Strata
  module UserFacingId
    # Encodes sequence integers into user-facing IDs and decodes them back.
    module Codec
      # Keyed Feistel permutation seed used to obfuscate sequence integers.
      #
      # Set once for a deployment and never rotated: every previously issued
      # user-facing ID is bound to the key it was encoded with, so changing this
      # value makes existing IDs unrecoverable. For per-attribute isolation,
      # pass a different `key:` to `user_facing_id_attribute` rather than
      # changing this default.
      DEFAULT_KEY = 0x5a3c_9e21
      SEGMENT_COUNT = 3

      # Total formatted space before reserving four low bits for parity.
      ENCODED_CAPACITY = Alphabet::BASE**SEGMENT_COUNT
      DATA_CAPACITY = ENCODED_CAPACITY / 16
      MAX_VALUE = DATA_CAPACITY - 1

      module_function

      def encode(value, prefix:, key: DEFAULT_KEY)
        integer = normalize_integer(value)
        validate_capacity!(integer)

        data_value = cycle_walk_encode(integer, key:)

        # Store parity in the low four bits before splitting into LNN segments.
        packed_value = Parity.append(data_value)
        segments = encode_segments(packed_value)

        ([ normalize_prefix(prefix) ] + segments).join("-")
      end

      def decode(value, prefix:, key: DEFAULT_KEY)
        packed_value = decode_segments(value, prefix:)
        data_value, parity = Parity.split(packed_value)

        validate_capacity!(data_value)
        Parity.validate!(data_value, parity)

        cycle_walk_decode(data_value, key:)
      end

      def normalize_prefix(prefix)
        normalized = prefix.to_s.strip.upcase
        return normalized if normalized.match?(/\A[A-Z0-9]+\z/)

        raise FormatError, "user-facing ID prefix must contain only letters and numbers"
      end

      def encode_segments(value)
        # Build right-to-left from the least-significant chunk, then unshift so the
        # most-significant segment appears first in the rendered ID.
        remaining = value
        segments = []
        SEGMENT_COUNT.times do
          remaining, chunk = remaining.divmod(Alphabet::BASE)
          segments.unshift(Alphabet.encode(chunk))
        end
        segments
      end

      def decode_segments(value, prefix:)
        expected_prefix = normalize_prefix(prefix)
        parts = value.to_s.strip.upcase.split("-")
        raise FormatError, "invalid user-facing ID format" unless parts.length == SEGMENT_COUNT + 1
        raise FormatError, "invalid user-facing ID prefix" unless parts.first == expected_prefix

        parts.drop(1).reduce(0) do |memo, segment|
          (memo * Alphabet::BASE) + Alphabet.decode(segment)
        end
      end

      def normalize_integer(value)
        Integer(value)
      rescue ArgumentError, TypeError
        raise ArgumentError, "user-facing ID source value must be an integer"
      end

      def validate_capacity!(value)
        return if value.between?(0, MAX_VALUE)

        raise RangeError, "user-facing ID source value must be between 0 and #{MAX_VALUE}"
      end

      def cycle_walk_encode(value, key:)
        current = value

        # Feistel permutes a power-of-two domain; cycle-walk until it lands in
        # the smaller displayable data domain.
        loop do
          current = Feistel.permute(current, key:)
          return current if current < DATA_CAPACITY
        end
      end

      def cycle_walk_decode(value, key:)
        current = value

        # Decoding mirrors the same cycle walk using the inverse permutation.
        loop do
          current = Feistel.invert(current, key:)
          return current if current < DATA_CAPACITY
        end
      end
    end
  end
end
