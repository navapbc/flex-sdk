module Flex
  # Money is a value object representing US dollar amounts stored as cents.
  # It uses composition instead of Integer inheritance due to Ruby's limitations
  # with immutable value types and to avoid ActiveSupport dependency issues.
  # Integer inheritance cannot work properly because you cannot override `new`
  # or call `super` in `initialize` for immutable value types.
  #
  # This class is used with MoneyAttribute to provide structured money handling
  # in form models.
  #
  # @example Creating a money object
  #   money = Flex::Money.new(1250)  # $12.50 in cents
  #   puts money.dollar_amount       # => 12.5
  #   puts money.to_s               # => "$12.50"
  #
  # Key features:
  # - Stores monetary values internally as cents (integer)
  # - Provides arithmetic operations that maintain type safety
  # - Formats money using sprintf for currency display
  # - Supports conversion between cents and dollar amounts
  #
  class Money
    include Comparable
    include ActiveSupport::NumberHelper

    attr_reader :cents

    # Initialize a new Money object with the given cents amount
    #
    # @param [Integer, Float, String] cents The amount in cents
    def initialize(cents)
      case cents
      when Integer
        @cents = cents
      when String
        begin
          @cents = Integer(cents)
        rescue ArgumentError
          raise ArgumentError, "String values must be valid integers representing cents"
        end
      else
        raise TypeError, "Expected Integer or String, got #{cents.class}"
      end
    end

    # Add another Money object or integer value
    #
    # @param [Money, Integer] other The value to add
    # @return [Money] A new Money object with the sum
    def +(other)
      other_cents = other.is_a?(Money) ? other.cents : other
      Money.new(@cents + other_cents)
    end

    # Subtract another Money object or integer value
    #
    # @param [Money, Integer] other The value to subtract
    # @return [Money] A new Money object with the difference
    def -(other)
      other_cents = other.is_a?(Money) ? other.cents : other
      Money.new(@cents - other_cents)
    end

    # Multiply by a scalar value
    #
    # @param [Integer, Float] scalar The multiplier
    # @return [Money] A new Money object with the product
    def *(scalar)
      Money.new((@cents * scalar.to_f).round)
    end

    # Divide by a scalar value, rounding down to nearest cent
    #
    # @param [Integer, Float] scalar The divisor
    # @return [Money] A new Money object with the quotient
    def /(scalar)
      Money.new((@cents / scalar.to_f).floor)
    end

    # Support coercion for commutative operations with integers and floats
    def coerce(other)
      [ self, other ]
    end

    # Returns the amount as a Float in dollars
    #
    # @return [Float] The dollar amount
    def dollar_amount
      @cents.to_f / 100
    end

    # Returns the amount as an Integer in cents
    #
    # @return [Integer] The cents amount
    def cents_amount
      @cents
    end

    # Returns a formatted currency string
    #
    # @return [String] The formatted currency (e.g., "$12.50")
    def to_s
      number_to_currency(dollar_amount)
    end

    # Comparison operator for Comparable
    #
    # @param [Money] other The other Money object to compare
    # @return [Integer] -1, 0, or 1
    def <=>(other)
      return nil unless other.is_a?(Money)
      @cents <=> other.cents
    end

    # Equality comparison for hash key functionality
    #
    # @param [Object] other The other object to compare
    # @return [Boolean] True if equal
    def eql?(other)
      (self <=> other) == 0
    end

    # Hash code for use in hashes and sets
    #
    # @return [Integer] The hash code
    def hash
      @cents.hash
    end
  end
end
