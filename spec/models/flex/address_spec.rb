require "rails_helper"

RSpec.describe Flex::Address do
  describe "initialization" do
    valid_params = {
      street_line_1: "123 Main St",
      street_line_2: "Apt 4B",
      city: "Anytown",
      state: "CA",
      zip_code: "12345"
    }

    describe "with valid inputs" do
      [
        [ "creates an Address with all fields", valid_params, true ],
        [ "allows street_line_2 to be nil", valid_params.merge(street_line_2: nil), true ],
        [ "allows street_line_2 to be empty", valid_params.merge(street_line_2: ""), true ],
        [ "accepts valid zip code with extension", valid_params.merge(zip_code: "12345-1234"), true ]
      ].each do |description, params, expected_valid|
        it description do
          address = described_class.new(params)
          expect(address.valid?).to eq(expected_valid)
        end
      end
    end

    describe "with invalid inputs" do
      [
        [ "requires street_line_1", valid_params.merge(street_line_1: nil), "street_line_1", "can't be blank" ],
        [ "requires city", valid_params.merge(city: nil), "city", "can't be blank" ],
        [ "requires state", valid_params.merge(state: nil), "state", "can't be blank" ],
        [ "requires state to be 2 characters", valid_params.merge(state: "C"), "state", "is the wrong length (should be 2 characters)" ],
        [ "requires state to not exceed 2 characters", valid_params.merge(state: "CAL"), "state", "is the wrong length (should be 2 characters)" ],
        [ "requires zip_code", valid_params.merge(zip_code: nil), "zip_code", "can't be blank" ],
        [ "requires valid zip format (5 digits)", valid_params.merge(zip_code: "1234"), "zip_code", "must be a valid US zip code" ],
        [ "requires valid zip format (not 6 digits)", valid_params.merge(zip_code: "123456"), "zip_code", "must be a valid US zip code" ],
        [ "requires valid zip+4 format", valid_params.merge(zip_code: "12345-123"), "zip_code", "must be a valid US zip code" ]
      ].each do |description, params, field, error_message|
        it description do
          address = described_class.new(params)
          expect(address).not_to be_valid
          expect(address.errors[field]).to include(error_message)
        end
      end
    end
  end

  describe "#to_s" do
    base_params = {
      street_line_1: "123 Main St",
      street_line_2: "Apt 4B",
      city: "Anytown",
      state: "CA",
      zip_code: "12345"
    }

    [
      [ "formats complete address",
        base_params,
        "123 Main St, Apt 4B, Anytown, CA 12345" ],
      [ "handles nil street_line_2",
        base_params.merge(street_line_2: nil),
        "123 Main St, Anytown, CA 12345" ],
      [ "handles empty street_line_2",
        base_params.merge(street_line_2: ""),
        "123 Main St, Anytown, CA 12345" ],
      [ "handles whitespace-only street_line_2",
        base_params.merge(street_line_2: "  "),
        "123 Main St, Anytown, CA 12345" ],
      [ "formats address with zip+4",
        base_params.merge(zip_code: "12345-1234"),
        "123 Main St, Apt 4B, Anytown, CA 12345-1234" ]
    ].each do |description, params, expected_string|
      it description do
        address = described_class.new(params)
        expect(address.to_s).to eq(expected_string)
      end
    end
  end

  describe "edge cases" do
    let(:base_params) do
      {
        street_line_1: "123 Main St",
        street_line_2: "Apt 4B",
        city: "Anytown",
        state: "CA",
        zip_code: "12345"
      }
    end

    it "handles very long input fields" do
      long_address = described_class.new(
        base_params.merge(
          street_line_1: "A" * 100,
          street_line_2: "B" * 100,
          city: "C" * 100
        )
      )
      expect(long_address).to be_valid
      expect(long_address.to_s).to include("A" * 100)
    end

    it "preserves leading/trailing spaces in components except street_line_2" do
      address = described_class.new(
        base_params.merge(
          street_line_1: "  123 Main St  ",
          city: "  Anytown  "
        )
      )
      expect(address.street_line_1).to eq("  123 Main St  ")
      expect(address.city).to eq("  Anytown  ")
    end
  end
end
