require "rails_helper"

RSpec.describe Flex::Money do
  describe "initialization" do
    [
      [ 1250, 1250, 12.5, "creates a Money object with integer cents" ],
      [ 0, 0, 0.0, "handles zero" ],
      [ -500, -500, -5.0, "handles negative values" ]
    ].each do |input, expected_cents, expected_dollars, description|
      it description do
        money = described_class.new(input)
        expect(money.cents_amount).to eq(expected_cents)
        expect(money.dollar_amount).to eq(expected_dollars)
      end
    end

    it "accepts valid string integers" do
      money = described_class.new("1500")
      expect(money.cents_amount).to eq(1500)
    end

    it "accepts whole number floats" do
      money = described_class.new(12.0)
      expect(money.cents_amount).to eq(12)
    end

    it "raises ArgumentError for non-integer floats" do
      expect { described_class.new(12.5) }.to raise_error(ArgumentError, "Float values must be whole numbers representing cents")
    end

    it "raises ArgumentError for invalid string values" do
      expect { described_class.new("12.5") }.to raise_error(ArgumentError, "String values must be valid integers representing cents")
      expect { described_class.new("abc") }.to raise_error(ArgumentError, "String values must be valid integers representing cents")
    end

    it "raises TypeError for unsupported types" do
      expect { described_class.new([]) }.to raise_error(TypeError, "Expected Integer, Float, or String, got Array")
      expect { described_class.new({}) }.to raise_error(TypeError, "Expected Integer, Float, or String, got Hash")
    end
  end

  describe "arithmetic operations" do
    let(:ten_dollars) { described_class.new(1000) }  # $10.00
    let(:five_dollars) { described_class.new(500) }   # $5.00

    describe "addition" do
      [
        [ 1000, 500, 1500, "adds two Money objects" ],
        [ 1000, 250, 1250, "adds Money and integer" ]
      ].each do |amount1, amount2, expected, description|
        it description do
          money_a = described_class.new(amount1)
          operand = amount2.is_a?(Integer) && description.include?("integer") ? amount2 : described_class.new(amount2)
          result = money_a + operand
          expect(result).to be_a(described_class)
          expect(result.cents_amount).to eq(expected)
        end
      end

      it "is commutative with integers" do
        result1 = ten_dollars + 250
        result2 = 250 + ten_dollars
        expect(result1.cents_amount).to eq(result2.cents_amount)
      end
    end

    describe "subtraction" do
      [
        [ 1000, 500, 500, "subtracts two Money objects" ],
        [ 1000, 250, 750, "subtracts integer from Money" ],
        [ 500, 1000, -500, "can result in negative values" ]
      ].each do |amount1, amount2, expected, description|
        it description do
          money_a = described_class.new(amount1)
          operand = amount2.is_a?(Integer) && description.include?("integer") ? amount2 : described_class.new(amount2)
          result = money_a - operand
          expect(result).to be_a(described_class)
          expect(result.cents_amount).to eq(expected)
        end
      end
    end

    describe "multiplication" do
      [
        [ 1000, 3, 3000, "multiplies Money by integer" ],
        [ 1000, 2.5, 2500, "multiplies Money by float" ],
        [ 333, 1.5, 500, "rounds to nearest cent" ],
        [ 1000, 0, 0, "handles zero multiplication" ],
        [ 1000, -2, -2000, "handles negative multiplication" ]
      ].each do |amount, multiplier, expected, description|
        it description do
          money = described_class.new(amount)
          result = money * multiplier
          expect(result).to be_a(described_class)
          expect(result.cents_amount).to eq(expected)
        end
      end
    end

    describe "division" do
      [
        [ 1001, 3, 333, "divides Money by integer, rounding down" ],
        [ 1000, 2.5, 400, "divides Money by float, rounding down" ],
        [ 1000, 2, 500, "handles exact division" ],
        [ 999, 3, 333, "always rounds down" ],
        [ 1000, -2, -500, "handles negative division" ]
      ].each do |amount, divisor, expected, description|
        it description do
          money = described_class.new(amount)
          result = money / divisor
          expect(result).to be_a(described_class)
          expect(result.cents_amount).to eq(expected)
        end
      end
    end
  end

  describe "conversion methods" do
    let(:money) { described_class.new(1234) }  # $12.34

    describe "#dollar_amount" do
      [
        [ 1234, 12.34, "returns amount as float in dollars" ],
        [ 0, 0.0, "handles zero" ],
        [ -500, -5.0, "handles negative amounts" ],
        [ 5, 0.05, "handles single cents" ]
      ].each do |cents, expected_dollars, description|
        it description do
          test_money = described_class.new(cents)
          expect(test_money.dollar_amount).to eq(expected_dollars)
        end
      end
    end

    describe "#cents_amount" do
      it "returns amount as integer in cents" do
        expect(money.cents_amount).to eq(1234)
      end

      it "is equivalent to the Money object itself" do
        expect(money.cents_amount).to eq(money.to_i)
      end
    end
  end

  describe "#to_s" do
    [
      [ 1234, "$12.34", "formats positive amounts as currency" ],
      [ 0, "$0.00", "formats zero as currency" ],
      [ -500, "-$5.00", "formats negative amounts as currency" ],
      [ 123456789, "$1234567.89", "formats large amounts correctly" ],
      [ 5, "$0.05", "formats small amounts correctly" ]
    ].each do |cents, expected_format, description|
      it description do
        money = described_class.new(cents)
        expect(money.to_s).to eq(expected_format)
      end
    end
  end

  describe "integer-like behavior" do
    let(:money) { described_class.new(1000) }

    it "converts to integer" do
      expect(money.to_i).to eq(1000)
    end

    it "supports Integer-like methods" do
      expect(money.abs.cents_amount).to eq(1000)
      expect(money.zero?).to be(false)
    end

    it "supports comparison" do
      money1 = described_class.new(500)
      money2 = described_class.new(1000)

      expect(money1 < money2).to be(true)
      expect(money2 > money1).to be(true)
      expect(money1 == described_class.new(500)).to be(true)
    end
  end

  describe "edge cases and error handling" do
    [
      [ 999999999999, 999999999999, 9999999999.99, "handles very large numbers" ],
      [ 1, 1, 0.01, "handles fractional cents in multiplication" ]
    ].each do |input, expected_cents, expected_dollars, description|
      it description do
        money = described_class.new(input)
        expect(money.cents_amount).to eq(expected_cents)
        expect(money.dollar_amount).to eq(expected_dollars)

        if description.include?("fractional")
          result = money * 0.5
          expect(result.cents_amount).to eq(1)
        end
      end
    end

    it "maintains precision in complex calculations" do
      money = described_class.new(1000)
      result = (money * 1.5) / 2
      expect(result.cents_amount).to eq(750)
    end
  end
end
