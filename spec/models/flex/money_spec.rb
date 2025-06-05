require "rails_helper"

RSpec.describe Flex::Money do
  describe "initialization" do
    [
      [ "creates a Money object with integer cents", 1250, 1250, 12.5 ],
      [ "handles zero", 0, 0, 0.0 ],
      [ "handles negative values", -500, -500, -5.0 ],
      [ "accepts valid string integers", "1500", 1500, 15.0 ],
      [ "accepts valid negative string integers", "-1500", -1500, -15.0 ]
    ].each do |description, input, expected_cents, expected_dollars|
      it description do
        money = described_class.new(input)
        expect(money.cents_amount).to eq(expected_cents)
        expect(money.dollar_amount).to eq(expected_dollars)
      end
    end

    [
      [ "raises type error for non-integer floats", 12.5, TypeError ],
      [ "raises type error for integer floats", 12.0, TypeError ],
      [ "raises type error for arrays", [], TypeError ],
      [ "raises type error for hashes", {}, TypeError ],
      [ "raises argument error for non-integer strings", "12.5", ArgumentError ],
      [ "raises argument error for non-numeric strings", "abc", ArgumentError ]
    ].each do |description, input, error_class|
      it description do
        expect { described_class.new(input) }.to raise_error(error_class)
      end
    end
  end

  describe "arithmetic operations" do
    let(:ten_dollars) { described_class.new(1000) }
    let(:five_dollars) { described_class.new(500) }

    describe "addition" do
      [
        [ "adds two Money objects", described_class.new(1000), described_class.new(500), described_class.new(1500) ],
        [ "adds Money and integer", described_class.new(1000), 250, described_class.new(1250) ],
        [ "is commutative with integers", 250, described_class.new(1000), described_class.new(1250) ]
      ].each do |description, money1, money2, expected|
        it description do
          result = money1 + money2
          expect(result).to be_a(described_class)
          expect(result.cents_amount).to eq(expected.cents_amount)
        end
      end
    end

    describe "subtraction" do
      [
        [ "subtracts two Money objects", described_class.new(1000), described_class.new(500), described_class.new(500) ],
        [ "subtracts integer from Money", described_class.new(1000), 250, described_class.new(750) ],
        [ "can result in negative values", described_class.new(500), described_class.new(1000), described_class.new(-500) ]
      ].each do |description, money1, money2, expected|
        it description do
          result = money1 - money2
          expect(result).to be_a(described_class)
          expect(result.cents_amount).to eq(expected.cents_amount)
        end
      end
    end

    describe "multiplication" do
      [
        [ "multiplies Money by integer", described_class.new(1000), 3, described_class.new(3000) ],
        [ "multiplies Money by float", described_class.new(1000), 2.5, described_class.new(2500) ],
        [ "rounds to nearest cent", described_class.new(333), 1.5, described_class.new(500) ],
        [ "handles zero multiplication", described_class.new(1000), 0, described_class.new(0) ],
        [ "handles negative multiplication", described_class.new(1000), -2, described_class.new(-2000) ]
      ].each do |description, money, multiplier, expected|
        it description do
          result = money * multiplier
          expect(result).to be_a(described_class)
          expect(result.cents_amount).to eq(expected.cents_amount)
        end
      end
    end

    describe "division" do
      [
        [ "divides Money by integer, rounding down", described_class.new(1001), 3, described_class.new(333) ],
        [ "divides Money by float, rounding down", described_class.new(1000), 2.5, described_class.new(400) ],
        [ "handles exact division", described_class.new(1000), 2, described_class.new(500) ],
        [ "always rounds down", described_class.new(999), 3, described_class.new(333) ],
        [ "handles negative division", described_class.new(1000), -2, described_class.new(-500) ]
      ].each do |description, money, divisor, expected|
        it description do
          result = money / divisor
          expect(result).to be_a(described_class)
          expect(result.cents_amount).to eq(expected.cents_amount)
        end
      end
    end
  end

  describe "conversion methods" do
    let(:money) { described_class.new(1234) }

    describe "#dollar_amount" do
      [
        [ "returns amount as float in dollars", 1234, 12.34 ],
        [ "handles zero", 0, 0.0 ],
        [ "handles negative amounts", -500, -5.0 ],
        [ "handles single cents", 5, 0.05 ]
      ].each do |description, cents, expected_dollars|
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
    end
  end

  describe "#to_s" do
    [
      [ "formats positive amounts as currency", 1234, "$12.34" ],
      [ "formats zero as currency", 0, "$0.00" ],
      [ "formats negative amounts as currency", -500, "-$5.00" ],
      [ "formats large amounts correctly", 123456789, "$1,234,567.89" ],
      [ "formats small amounts correctly", 5, "$0.05" ]
    ].each do |description, cents, expected_format|
      it description do
        money = described_class.new(cents)
        expect(money.to_s).to eq(expected_format)
      end
    end
  end

  describe "edge cases and error handling" do
    [
      [ "handles very large numbers", 999999999999, 999999999999, 9999999999.99 ],
      [ "handles fractional cents in multiplication", 1, 1, 0.01 ]
    ].each do |description, input, expected_cents, expected_dollars|
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

  describe "hash key usage" do
    it "can be used as hash keys" do
      hash = {
        described_class.new(1000) => "ten dollars",
        described_class.new(500) => "five dollars"
      }

      expect(hash[described_class.new(1000)]).to eq("ten dollars")
      expect(hash[described_class.new(500)]).to eq("five dollars")
      expect(hash[described_class.new(2000)]).to be_nil
    end

    it "treats equal amounts as the same key" do
      hash = { described_class.new(1000) => "original" }
      hash[described_class.new(1000)] = "updated"

      expect(hash.size).to eq(1)
      expect(hash[described_class.new(1000)]).to eq("updated")
    end
  end

  describe "sorting" do
    it "can be sorted" do
      amounts = [
        described_class.new(1500),
        described_class.new(500),
        described_class.new(1000),
        described_class.new(1000),
        described_class.new(0),
        described_class.new(1000),
        described_class.new(-500)
      ]

      sorted = amounts.sort

      expect(sorted.map(&:cents_amount)).to eq([ -500, 0, 500, 1000, 1000, 1000, 1500 ])
    end

    it "can't be compared with non-Money objects" do
      money = described_class.new(1000)
      expect(money <=> "not a money object").to be_nil
      expect(money <=> nil).to be_nil
      expect(nil <=> money).to be_nil
    end
  end
end
