module Flex
  # Money is a value object representing US dollar amounts stored as cents.
  # It inherits from Integer but adds arithmetic operations and formatting
  # capabilities for monetary values.
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
  # - Formats money using Rails' number_to_currency helper
  # - Supports conversion between cents and dollar amounts
  #
  class Money < Integer
    include ActiveSupport::NumberHelper

    # Initialize a new Money object with the given cents amount
    #
    # @param [Integer, Float, String] cents The amount in cents
    def initialize(cents)
      super(cents.to_i)
    end

    # Add another Money object or integer value
    #
    # @param [Money, Integer] other The value to add
    # @return [Money] A new Money object with the sum
    def +(other)
      Money.new(super(other.is_a?(Money) ? other : other.to_i))
    end

    # Subtract another Money object or integer value
    #
    # @param [Money, Integer] other The value to subtract
    # @return [Money] A new Money object with the difference
    def -(other)
      Money.new(super(other.is_a?(Money) ? other : other.to_i))
    end

    # Multiply by a scalar value
    #
    # @param [Integer, Float] scalar The multiplier
    # @return [Money] A new Money object with the product
    def *(scalar)
      Money.new((to_f * scalar.to_f).round)
    end

    # Divide by a scalar value, rounding down to nearest cent
    #
    # @param [Integer, Float] scalar The divisor
    # @return [Money] A new Money object with the quotient
    def /(scalar)
      Money.new((to_f / scalar.to_f).floor)
    end

    # Returns the amount as a Float in dollars
    #
    # @return [Float] The dollar amount
    def dollar_amount
      to_f / 100
    end

    # Returns the amount as an Integer in cents
    #
    # @return [Integer] The cents amount
    def cents_amount
      self
    end

    # Returns a formatted currency string
    #
    # @return [String] The formatted currency (e.g., "$12.50")
    def to_s
      number_to_currency(dollar_amount)
    end
  end
end
