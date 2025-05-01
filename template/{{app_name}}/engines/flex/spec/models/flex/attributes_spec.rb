require "rails_helper"

RSpec.describe Flex::Attributes do
  before do
    test_model = Class.new do
      include ActiveModel::Attributes
      include ActiveModel::Validations
      include Flex::Attributes

      flex_attribute :test_date, :memorable_date
    end
    stub_const "TestModel", test_model
  end

  let(:object) { TestModel.new }

  describe "memorable_date attribute" do
    it "allows setting a Date" do
      object.test_date = Date.new(2020, 1, 1)
      expect(object.test_date).to eq("2020-01-01")
    end

    it "allows setting a Hash with year, month, and day" do
      object.test_date = { year: 2020, month: 1, day: 1 }
      expect(object.test_date).to eq("2020-01-01")
    end

    [
      { year: 2020, month: 1, day: -1 },
      { year: 2020, month: 1, day: 0 },
      { year: 2020, month: 1, day: 32 },
      { year: 2020, month: -1, day: 1 },
      { year: 2020, month: 0, day: 1 },
      { year: 2020, month: 13, day: 1 },
      { year: 2020, month: 2, day: 30 }
    ].each do |date|
      it "validates that date is a valid date" do
        object.test_date = date
        expect(object.test_date).to eq("%04d-%02d-%02d" % [ date[:year], date[:month], date[:day] ])
        expect(object).not_to be_valid
        expect(object.errors["test_date"]).to include("is not a valid date")
      end
    end
  end
end
