module Flex
  # Money is a value object representing US dollar amounts stored as cents.
  # It uses composition to wrap an Integer value and provides arithmetic
  # operations and formatting capabilities for monetary values.
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

    attr_reader :cents

    # Initialize a new Money object with the given cents amount
    #
    # @param [Integer, Float, String] cents The amount in cents
    def initialize(cents)
      @cents = case cents
      when Integer
        cents
      when Float
        raise ArgumentError, "Float values must be whole numbers representing cents" unless cents == cents.to_i
        cents.to_i
      when String
        parsed = Integer(cents) rescue nil
        raise ArgumentError, "String values must be valid integers representing cents" if parsed.nil?
        parsed
      else
        raise TypeError, "Expected Integer, Float, or String, got #{cents.class}"
      end
    end

    # Add another Money object or integer value
    #
    # @param [Money, Integer] other The value to add
    # @return [Money] A new Money object with the sum
    def +(other)
      other_cents = other.is_a?(Money) ? other.cents : other.to_i
      Money.new(@cents + other_cents)
    end

    # Support coercion for commutative operations with integers
    def coerce(other)
      [ Money.new(other), self ]
    end

    # Subtract another Money object or integer value
    #
    # @param [Money, Integer] other The value to subtract
    # @return [Money] A new Money object with the difference
    def -(other)
      other_cents = other.is_a?(Money) ? other.cents : other.to_i
      Money.new(@cents - other_cents)
    end

    # Multiply by a scalar value
    #
    # @param [Integer, Float] scalar The multiplier
    # @return [Money] A new Money object with the product
    def *(scalar)
      Money.new((@cents.to_f * scalar.to_f).round)
    end

    # Divide by a scalar value, rounding down to nearest cent
    #
    # @param [Integer, Float] scalar The divisor
    # @return [Money] A new Money object with the quotient
    def /(scalar)
      Money.new((@cents.to_f / scalar.to_f).floor)
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
      if @cents < 0
        sprintf("-$%.2f", dollar_amount.abs)
      else
        sprintf("$%.2f", dollar_amount)
      end
    end

    # Comparison operator for Comparable
    #
    # @param [Money] other The other Money object to compare
    # @return [Integer] -1, 0, or 1
    def <=>(other)
      return nil unless other.is_a?(Money)
      @cents <=> other.cents
    end

    # Equality comparison
    #
    # @param [Object] other The other object to compare
    # @return [Boolean] True if equal
    def ==(other)
      other.is_a?(Money) && @cents == other.cents
    end

    # Hash code for use in hashes and sets
    #
    # @return [Integer] The hash code
    def hash
      @cents.hash
    end

    # Convert to integer (cents)
    #
    # @return [Integer] The cents amount
    def to_i
      @cents
    end

    # Convert to float (cents)
    #
    # @return [Float] The cents amount as float
    def to_f
      @cents.to_f
    end

    # Check if zero
    #
    # @return [Boolean] True if zero cents
    def zero?
      @cents.zero?
    end

    # Absolute value
    #
    # @return [Money] A new Money object with absolute value
    def abs
      Money.new(@cents.abs)
    end
  end
end
