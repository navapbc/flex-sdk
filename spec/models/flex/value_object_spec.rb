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

    [
        [ 1, 2, "hello", true ],
        [ 0, 2, "hello", false ],
        [ 1, 1, "hello", false ],
        [ 1, 2, "goodbye", false ]
    ].each do |x, y, foo, expected|
      it "compares by attribute [#{x}, #{y}, #{foo}]" do
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

  describe '#blank?' do
    let(:blank_klass) do
      Class.new(described_class) do
        attribute :a, :string
        attribute :b, :string
        attribute :c, :string
      end
    end

    [
      [ 'all nil components', { a: nil, b: nil, c: nil }, true ],
      [ 'all empty string components', { a: '', b: '', c: '' }, true ],
      [ 'all whitespace components', { a: '  ', b: '  ', c: '  ' }, true ],
      [ 'mixed nil and empty', { a: nil, b: '', c: nil }, true ],
      [ 'mixed nil and whitespace', { a: nil, b: '  ', c: '' }, true ],
      [ 'one non-blank component', { a: 'value', b: nil, c: nil }, false ],
      [ 'mixed blank and non-blank', { a: 'value', b: '  ', c: '' }, false ],
      [ 'all components present', { a: 'one', b: 'two', c: 'three' }, false ]
    ].each do |description, attributes, expected|
      it "returns #{expected} when #{description}" do
        object = blank_klass.new(attributes)
        expect(object.blank?).to eq(expected)
      end
    end
  end

  describe '#present?' do
    let(:present_klass) do
      Class.new(described_class) do
        attribute :a, :string
        attribute :b, :string
        attribute :c, :string
      end
    end

    [
      [ 'all nil components', { a: nil, b: nil, c: nil }, false ],
      [ 'all empty string components', { a: '', b: '', c: '' }, false ],
      [ 'all whitespace components', { a: '  ', b: '  ', c: '  ' }, false ],
      [ 'mixed nil and empty', { a: nil, b: '', c: nil }, false ],
      [ 'mixed nil and whitespace', { a: nil, b: '  ', c: '' }, false ],
      [ 'one non-blank component', { a: 'value', b: nil, c: nil }, true ],
      [ 'mixed blank and non-blank', { a: 'value', b: '  ', c: '' }, true ],
      [ 'all components present', { a: 'one', b: 'two', c: 'three' }, true ]
    ].each do |description, attributes, expected|
      it "returns #{expected} when #{description}" do
        object = present_klass.new(attributes)
        expect(object.present?).to eq(expected)
      end
    end
  end
end
