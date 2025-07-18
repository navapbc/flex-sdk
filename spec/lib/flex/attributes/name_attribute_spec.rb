require "rails_helper"

RSpec.describe Flex::Attributes::NameAttribute do
  let(:object) { TestRecord.new }
  let(:first) { "Jane" }
  let(:middle) { "Marie" }
  let(:last) { "Doe" }

  it "allows setting name as a value object" do
    name = Flex::Name.new(first:, middle:, last:)
    object.name = name

    expect(object.name).to eq(Flex::Name.new(first:, middle:, last:))
    expect(object.name_first).to eq(first)
    expect(object.name_middle).to eq(middle)
    expect(object.name_last).to eq(last)
  end

  it "allows setting name as a hash" do
    object.name = { first: first, middle: middle, last: last }

    expect(object.name).to eq(Flex::Name.new(first:, middle:, last:))
    expect(object.name_first).to eq(first)
    expect(object.name_middle).to eq(middle)
    expect(object.name_last).to eq(last)
  end

  it "allows setting nested name attributes directly" do
    object.name_first = first
    object.name_middle = middle
    object.name_last = last
    expect(object.name).to eq(Flex::Name.new(first:, middle:, last:))
  end

  it "preserves values exactly as entered without normalization" do
    object.name = { first: "jean-luc", middle: "von", last: "O'REILLY" }

    expect(object.name).to eq(Flex::Name.new(first: "jean-luc", middle: "von", last: "O'REILLY"))
    expect(object.name_first).to eq("jean-luc")
    expect(object.name_middle).to eq("von")
    expect(object.name_last).to eq("O'REILLY")
  end

  it "persists and loads name object correctly" do
    name = Flex::Name.new(first: "John", middle: "Middle", last: "Doe")
    object.name = name
    object.save!

    loaded_record = TestRecord.find(object.id)
    expect(loaded_record.name).to be_a(Flex::Name)
    expect(loaded_record.name).to eq(name)
    expect(loaded_record.name_first).to eq("John")
    expect(loaded_record.name_middle).to eq("Middle")
    expect(loaded_record.name_last).to eq("Doe")
  end

  describe "array: true" do
    it "allows setting an array of names" do
      names = [
        Flex::Name.new(first: "John", last: "Smith"),
        Flex::Name.new(first: "Jane", middle: "Marie", last: "Doe")
      ]
      object.names = names

      expect(object.names).to be_an(Array)
      expect(object.names.size).to eq(2)
      expect(object.names[0]).to eq(names[0])
      expect(object.names[1]).to eq(names[1])
    end

    it "persists and loads arrays of value objects" do
      name_1 = build(:name, :base)
      name_2 = build(:name, :base, :with_middle)
      object.names = [ name_1, name_2 ]

      object.save!
      loaded_record = TestRecord.find(object.id)

      expect(loaded_record.names.size).to eq(2)
      expect(loaded_record.names[0]).to eq(name_1)
      expect(loaded_record.names[1]).to eq(name_2)
    end
  end
end
