require "rails_helper"

RSpec.describe Flex::Attributes::MoneyAttribute do
  let(:object) { TestRecord.new }

  it "allows setting money as a Money object" do
    money = Flex::Money.new(cents: 1250)
    object.weekly_wage = money

    expect(object.weekly_wage).to be_a(Flex::Money)
    expect(object.weekly_wage.cents_amount).to eq(1250)
    expect(object.weekly_wage.dollar_amount).to eq(12.5)
  end

  it "allows setting money as an integer (cents)" do
    object.weekly_wage = 2500

    expect(object.weekly_wage).to be_a(Flex::Money)
    expect(object.weekly_wage.cents_amount).to eq(2500)
    expect(object.weekly_wage.dollar_amount).to eq(25.0)
  end

  it "allows setting money as a hash with dollar_amount" do
    object.weekly_wage = { dollar_amount: 10.50 }

    expect(object.weekly_wage).to be_a(Flex::Money)
    expect(object.weekly_wage.cents_amount).to eq(1050)
    expect(object.weekly_wage.dollar_amount).to eq(10.5)
  end

  describe "edge cases" do
    it "handles nil values" do
      object.weekly_wage = nil
      expect(object.weekly_wage).to be_nil
    end

    it "handles zero values" do
      object.weekly_wage = 0
      expect(object.weekly_wage).to be_a(Flex::Money)
      expect(object.weekly_wage.cents_amount).to eq(0)
      expect(object.weekly_wage.dollar_amount).to eq(0.0)
      expect(object.weekly_wage.to_s).to eq("$0.00")
    end

    it "handles negative values" do
      object.weekly_wage = -500
      expect(object.weekly_wage).to be_a(Flex::Money)
      expect(object.weekly_wage.cents_amount).to eq(-500)
      expect(object.weekly_wage.dollar_amount).to eq(-5.0)
      expect(object.weekly_wage.to_s).to eq("-$5.00")
    end

    it "handles hash with string keys" do
      object.weekly_wage = { "dollar_amount" => "12.34" }
      expect(object.weekly_wage).to be_a(Flex::Money)
      expect(object.weekly_wage.cents_amount).to eq(1234)
      expect(object.weekly_wage.dollar_amount).to eq(12.34)
    end

    it "returns nil for invalid hash" do
      object.weekly_wage = { invalid_key: 100 }
      expect(object.weekly_wage).to be_nil
    end

    it "returns nil for unsupported types" do
      object.weekly_wage = 15.75
      expect(object.weekly_wage).to be_nil
    end
  end

  describe "persistence" do
    it "persists and loads money object correctly" do
      money = Flex::Money.new(cents: 1250)
      object.weekly_wage = money
      object.save!

      loaded_record = TestRecord.find(object.id)
      expect(loaded_record.weekly_wage).to be_a(Flex::Money)
      expect(loaded_record.weekly_wage).to eq(money)
      expect(loaded_record.weekly_wage.cents_amount).to eq(1250)
      expect(loaded_record.weekly_wage.dollar_amount).to eq(12.5)
    end
  end
end
