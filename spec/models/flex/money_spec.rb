require "rails_helper"

RSpec.describe Flex::Money do
  describe "initialization" do
    it "creates a Money object with integer cents" do
      money = Flex::Money.new(1250)
      expect(money.cents_amount).to eq(1250)
      expect(money.dollar_amount).to eq(12.5)
    end

    it "converts float to integer cents" do
      money = Flex::Money.new(12.5)
      expect(money.cents_amount).to eq(12)
    end

    it "converts string to integer cents" do
      money = Flex::Money.new("1500")
      expect(money.cents_amount).to eq(1500)
    end

    it "handles zero" do
      money = Flex::Money.new(0)
      expect(money.cents_amount).to eq(0)
      expect(money.dollar_amount).to eq(0.0)
    end

    it "handles negative values" do
      money = Flex::Money.new(-500)
      expect(money.cents_amount).to eq(-500)
      expect(money.dollar_amount).to eq(-5.0)
    end
  end

  describe "arithmetic operations" do
    let(:money1) { Flex::Money.new(1000) }  # $10.00
    let(:money2) { Flex::Money.new(500) }   # $5.00

    describe "addition" do
      it "adds two Money objects" do
        result = money1 + money2
        expect(result).to be_a(Flex::Money)
        expect(result.cents_amount).to eq(1500)
      end

      it "adds Money and integer" do
        result = money1 + 250
        expect(result).to be_a(Flex::Money)
        expect(result.cents_amount).to eq(1250)
      end

      it "is commutative with integers" do
        result1 = money1 + 250
        result2 = 250 + money1
        expect(result1.cents_amount).to eq(result2.cents_amount)
      end
    end

    describe "subtraction" do
      it "subtracts two Money objects" do
        result = money1 - money2
        expect(result).to be_a(Flex::Money)
        expect(result.cents_amount).to eq(500)
      end

      it "subtracts integer from Money" do
        result = money1 - 250
        expect(result).to be_a(Flex::Money)
        expect(result.cents_amount).to eq(750)
      end

      it "can result in negative values" do
        result = money2 - money1
        expect(result).to be_a(Flex::Money)
        expect(result.cents_amount).to eq(-500)
      end
    end

    describe "multiplication" do
      it "multiplies Money by integer" do
        result = money1 * 3
        expect(result).to be_a(Flex::Money)
        expect(result.cents_amount).to eq(3000)
      end

      it "multiplies Money by float" do
        result = money1 * 2.5
        expect(result).to be_a(Flex::Money)
        expect(result.cents_amount).to eq(2500)
      end

      it "rounds to nearest cent" do
        money = Flex::Money.new(333)  # $3.33
        result = money * 1.5
        expect(result.cents_amount).to eq(500)  # 333 * 1.5 = 499.5, rounded to 500
      end

      it "handles zero multiplication" do
        result = money1 * 0
        expect(result).to be_a(Flex::Money)
        expect(result.cents_amount).to eq(0)
      end

      it "handles negative multiplication" do
        result = money1 * -2
        expect(result).to be_a(Flex::Money)
        expect(result.cents_amount).to eq(-2000)
      end
    end

    describe "division" do
      it "divides Money by integer, rounding down" do
        money = Flex::Money.new(1001)  # $10.01
        result = money / 3
        expect(result).to be_a(Flex::Money)
        expect(result.cents_amount).to eq(333)  # 1001 / 3 = 333.67, floored to 333
      end

      it "divides Money by float, rounding down" do
        money = Flex::Money.new(1000)  # $10.00
        result = money / 2.5
        expect(result).to be_a(Flex::Money)
        expect(result.cents_amount).to eq(400)  # 1000 / 2.5 = 400.0
      end

      it "handles exact division" do
        result = money1 / 2
        expect(result).to be_a(Flex::Money)
        expect(result.cents_amount).to eq(500)
      end

      it "always rounds down" do
        money = Flex::Money.new(999)  # $9.99
        result = money / 3
        expect(result.cents_amount).to eq(333)  # 999 / 3 = 333.0
      end

      it "handles negative division" do
        result = money1 / -2
        expect(result).to be_a(Flex::Money)
        expect(result.cents_amount).to eq(-500)
      end
    end
  end

  describe "conversion methods" do
    let(:money) { Flex::Money.new(1234) }  # $12.34

    describe "#dollar_amount" do
      it "returns amount as float in dollars" do
        expect(money.dollar_amount).to eq(12.34)
      end

      it "handles zero" do
        zero_money = Flex::Money.new(0)
        expect(zero_money.dollar_amount).to eq(0.0)
      end

      it "handles negative amounts" do
        negative_money = Flex::Money.new(-500)
        expect(negative_money.dollar_amount).to eq(-5.0)
      end

      it "handles single cents" do
        small_money = Flex::Money.new(5)
        expect(small_money.dollar_amount).to eq(0.05)
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
    it "formats positive amounts as currency" do
      money = Flex::Money.new(1234)
      expect(money.to_s).to eq("$12.34")
    end

    it "formats zero as currency" do
      money = Flex::Money.new(0)
      expect(money.to_s).to eq("$0.00")
    end

    it "formats negative amounts as currency" do
      money = Flex::Money.new(-500)
      expect(money.to_s).to eq("-$5.00")
    end

    it "formats large amounts correctly" do
      money = Flex::Money.new(123456789)  # $1,234,567.89
      expect(money.to_s).to eq("$1,234,567.89")
    end

    it "formats small amounts correctly" do
      money = Flex::Money.new(5)  # $0.05
      expect(money.to_s).to eq("$0.05")
    end
  end

  describe "inheritance from Integer" do
    let(:money) { Flex::Money.new(1000) }

    it "behaves like an Integer" do
      expect(money).to be_a(Integer)
      expect(money.to_i).to eq(1000)
    end

    it "supports Integer methods" do
      expect(money.abs).to eq(1000)
      expect(money.zero?).to be(false)
    end

    it "supports comparison" do
      money1 = Flex::Money.new(500)
      money2 = Flex::Money.new(1000)
      
      expect(money1 < money2).to be(true)
      expect(money2 > money1).to be(true)
      expect(money1 == Flex::Money.new(500)).to be(true)
    end
  end

  describe "edge cases and error handling" do
    it "handles very large numbers" do
      large_money = Flex::Money.new(999999999999)
      expect(large_money.cents_amount).to eq(999999999999)
      expect(large_money.dollar_amount).to eq(9999999999.99)
    end

    it "handles fractional cents in multiplication" do
      money = Flex::Money.new(1)  # $0.01
      result = money * 0.5
      expect(result.cents_amount).to eq(1)  # Rounds 0.5 to 1
    end

    it "maintains precision in complex calculations" do
      money = Flex::Money.new(1000)  # $10.00
      result = (money * 1.5) / 2
      expect(result.cents_amount).to eq(750)  # (1000 * 1.5) / 2 = 750
    end
  end
end
