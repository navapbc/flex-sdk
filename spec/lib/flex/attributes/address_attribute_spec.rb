require "rails_helper"

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Flex::Attributes::AddressAttribute do
  let(:object) { TestRecord.new }
  let(:street_line_1) { "456 Oak Ave" } # rubocop:disable RSpec/IndexedLet
  let(:street_line_2) { "Unit 7C" } # rubocop:disable RSpec/IndexedLet
  let(:city) { "San Francisco" }
  let(:state) { "CA" }
  let(:zip_code) { "94107" }

  it "allows setting address as a value object" do
    address = Flex::Address.new(street_line_1:, street_line_2:, city:, state:, zip_code:)
    object.address = address

    expect(object.address).to eq(Flex::Address.new(street_line_1:, street_line_2:, city:, state:, zip_code:))
    expect(object.address_street_line_1).to eq(street_line_1)
    expect(object.address_street_line_2).to eq(street_line_2)
    expect(object.address_city).to eq(city)
    expect(object.address_state).to eq(state)
    expect(object.address_zip_code).to eq(zip_code)
  end

  it "allows setting address as a hash" do
    object.address = {
      street_line_1:,
      street_line_2:,
      city:,
      state:,
      zip_code:
    }

    expect(object.address).to eq(Flex::Address.new(street_line_1:, street_line_2:, city:, state:, zip_code:))
    expect(object.address_street_line_1).to eq(street_line_1)
    expect(object.address_street_line_2).to eq(street_line_2)
    expect(object.address_city).to eq(city)
    expect(object.address_state).to eq(state)
    expect(object.address_zip_code).to eq(zip_code)
  end

  it "allows setting nested address attributes directly" do
    object.address_street_line_1 = street_line_1
    object.address_street_line_2 = street_line_2
    object.address_city = city
    object.address_state = state
    object.address_zip_code = zip_code
    expect(object.address).to eq(Flex::Address.new(street_line_1:, street_line_2:, city:, state:, zip_code:))
  end

  it "preserves values exactly as entered without normalization" do
    object.address = {
      street_line_1: "789 BROADWAY",
      street_line_2: "",
      city: "new york",
      state: "NY",
      zip_code: "10003"
    }

    expect(object.address).to eq(Flex::Address.new(street_line_1: "789 BROADWAY", street_line_2: "", city: "new york", state: "NY", zip_code: "10003"))
    expect(object.address_street_line_1).to eq("789 BROADWAY")
    expect(object.address_street_line_2).to eq("")
    expect(object.address_city).to eq("new york")
    expect(object.address_state).to eq("NY")
    expect(object.address_zip_code).to eq("10003")
  end

  it "persists and loads address object correctly" do
    address = Flex::Address.new(street_line_1: "123 Main St", street_line_2: "Apt 4B", city: "Boston", state: "MA", zip_code: "02108")
    object.address = address
    object.save!

    loaded_record = TestRecord.find(object.id)
    expect(loaded_record.address).to be_a(Flex::Address)
    expect(loaded_record.address).to eq(address)
    expect(loaded_record.address_street_line_1).to eq("123 Main St")
    expect(loaded_record.address_street_line_2).to eq("Apt 4B")
    expect(loaded_record.address_city).to eq("Boston")
    expect(loaded_record.address_state).to eq("MA")
    expect(loaded_record.address_zip_code).to eq("02108")
  end

  describe "array: true" do
    it "allows setting an array of addresses" do
      addresses = [
        build(:address, :base),
        build(:address, :base)
      ]
      object.addresses = addresses

      expect(object.addresses).to be_an(Array)
      expect(object.addresses.size).to eq(2)
      expect(object.addresses[0]).to eq(addresses[0])
      expect(object.addresses[1]).to eq(addresses[1])
    end

    it "validates each address in the array" do
      object.addresses = [
        Flex::Address.new(street_line_1: "123 Main St", state: "MA", zip_code: "02108"), # Invalid: missing city
        build(:address, :base) # Valid
      ]

      expect(object).not_to be_valid
      expect(object.errors[:addresses]).to include("contains one or more invalid items")
    end

    it "persists and loads arrays of value objects" do
      address_1 = build(:address, :base)
      address_2 = build(:address, :base)
      object.addresses = [ address_1, address_2 ]

      object.save!
      loaded_record = TestRecord.find(object.id)

      expect(loaded_record.addresses.size).to eq(2)
      expect(loaded_record.addresses[0]).to eq(address_1)
      expect(loaded_record.addresses[1]).to eq(address_2)
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
