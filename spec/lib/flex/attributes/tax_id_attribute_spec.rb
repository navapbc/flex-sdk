require "rails_helper"

RSpec.describe Flex::Attributes::TaxIdAttribute do
  let(:object) { TestRecord.new }

  it "allows setting a tax_id as a TaxId object" do
    tax_id = Flex::TaxId.new("123456789")
    object.tax_id = tax_id

    expect(object.tax_id).to be_a(Flex::TaxId)
    expect(object.tax_id.formatted).to eq("123-45-6789")
  end

  it "allows setting a tax_id as a string" do
    object.tax_id = "123456789"

    expect(object.tax_id).to be_a(Flex::TaxId)
    expect(object.tax_id.formatted).to eq("123-45-6789")
  end

  [
    [ "123456789", "123-45-6789" ],
    [ "123-45-6789", "123-45-6789" ],
    [ "123 45 6789", "123-45-6789" ]
  ].each do |input_string, expected|
    it "formats tax_id correctly [#{input_string}]" do
      object.tax_id = input_string
      expect(object.tax_id.formatted).to eq(expected)
    end
  end

  it "preserves invalid values for validation" do
    object.tax_id = "12345"

    expect(object.tax_id).to be_a(Flex::TaxId)
    expect(object.tax_id.formatted).to eq("12345") # Raw value since not 9 digits
    expect(object).not_to be_valid
    expect(object.errors.full_messages_for("tax_id")).to eq([ "Tax ID is not a valid Taxpayer Identification Number (TIN). Use the format (XXX-XX-XXXX)" ])
  end

  describe "TaxId.<=>" do
    it "allows sorting tax ids" do
      tax_ids = [
        Flex::TaxId.new("987654321"),
        Flex::TaxId.new("123456789"),
        Flex::TaxId.new("456789123")
      ]

      sorted_tax_ids = tax_ids.sort
      expect(sorted_tax_ids.map(&:formatted)).to eq([
        "123-45-6789",
        "456-78-9123",
        "987-65-4321"
      ])
    end

    it "compares tax ids numerically" do
      lower = Flex::TaxId.new("123456789")
      higher = Flex::TaxId.new("987654321")

      expect(lower <=> higher).to eq(-1)
      expect(higher <=> lower).to eq(1)
      expect(lower <=> lower).to eq(0)
    end

    it "handles comparison with different formats" do
      tax_id1 = Flex::TaxId.new("123-45-6789")
      tax_id2 = Flex::TaxId.new("123456789")

      expect(tax_id1 <=> tax_id2).to eq(0)
    end

    it "handles comparison with string values" do
      tax_id = Flex::TaxId.new("123-45-6789")
      string_value = "123456789"

      expect(tax_id <=> string_value).to eq(0)
    end
  end

  describe "persistence" do
    it "persists and loads tax_id object correctly" do
      tax_id = Flex::TaxId.new("123-45-6789")
      object.tax_id = tax_id
      object.save!

      loaded_record = TestRecord.find(object.id)
      expect(loaded_record.tax_id).to be_a(Flex::TaxId)
      expect(loaded_record.tax_id).to eq(tax_id)
      expect(loaded_record.tax_id.formatted).to eq("123-45-6789")
    end
  end
end
