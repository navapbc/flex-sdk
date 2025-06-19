require 'rails_helper'

RSpec.describe Flex::ValueObject do
  let(:klass) do
    Class.new(described_class) do
      attribute :x, :integer
      attribute :y, :integer
      attribute :foo, :string
    end
  end

  describe ".new" do
    it "instantiates an empty object" do
      object = klass.new
      expect(object.x).to be_nil
      expect(object.y).to be_nil
      expect(object.foo).to be_nil
    end

    it "creates an object from a hash" do
      x = 1
      y = 2
      foo = "hello, world"      
      object = klass.new(x:, y:, foo:)
      expect(object.x).to eq(x)
      expect(object.y).to eq(y)
      expect(object.foo).to eq(foo)
    end
  end

  describe "#==" do
    let(:object) { klass.new(x: 1, y: 2, foo: "hello") }

    it "compares by attribute" do
      [
        [1, 2, "hello", true],
        [0, 2, "hello", false],
        [1, 1, "hello", false],
        [1, 2, "goodbye", false],
      ].each do |x, y, foo, expected|
        expect(object == klass.new(x:, y:, foo:)).to be expected
      end
    end
  end

  describe "serialization" do
    let(:object) { klass.new(x: 1, y: 2, foo: "hello") }
    it "serializes to json" do
      expect(object.to_json).to eq("{\"x\":1,\"y\":2,\"foo\":\"hello\"}")
    end
  end
end
