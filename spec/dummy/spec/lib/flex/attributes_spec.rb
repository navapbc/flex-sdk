require "rails_helper"

RSpec.describe Strata::Attributes do
  let(:object) { TestRecord.new }

  describe "persisting and loading from database" do
    it "preserves all attributes when saving and loading multiple value objects" do
      name = build(:name, :with_middle)
      address = build(:address, :base, :with_street_line_2)
      object.name = name
      object.address = address
      object.tax_id = Strata::TaxId.new("987-65-4321")
      object.weekly_wage = Strata::Money.new(cents: 5000)
      object.date_of_birth = Strata::USDate.new(1990, 3, 15)
      object.period = Strata::DateRange.new(start: Strata::USDate.new(2023, 1, 1), end: Strata::USDate.new(2023, 12, 31))
      object.save!

      loaded_record = TestRecord.find(object.id)

      # Verify name
      expect(loaded_record.name).to eq(name)
      expect(loaded_record.name_first).to eq(name.first)
      expect(loaded_record.name_middle).to eq(name.middle)
      expect(loaded_record.name_last).to eq(name.last)

      # Verify address
      expect(loaded_record.address).to eq(address)
      expect(loaded_record.address_street_line_1).to eq(address.street_line_1)
      expect(loaded_record.address_street_line_2).to eq(address.street_line_2)
      expect(loaded_record.address_city).to eq(address.city)
      expect(loaded_record.address_state).to eq(address.state)
      expect(loaded_record.address_zip_code).to eq(address.zip_code)

      # Verify tax_id
      expect(loaded_record.tax_id).to eq(Strata::TaxId.new("987-65-4321"))
      expect(loaded_record.tax_id.formatted).to eq("987-65-4321")

      # Verify money
      expect(loaded_record.weekly_wage).to eq(Strata::Money.new(cents: 5000))
      expect(loaded_record.weekly_wage.cents_amount).to eq(5000)
      expect(loaded_record.weekly_wage.dollar_amount).to eq(50.0)

      # Verify date_of_birth
      expect(loaded_record.date_of_birth).to eq(Strata::USDate.new(1990, 3, 15))

      # Verify date_range
      expect(loaded_record.period).to eq(Strata::DateRange.new(start: Strata::USDate.new(2023, 1, 1), end: Strata::USDate.new(2023, 12, 31)))
      expect(loaded_record.period_start).to eq(Strata::USDate.new(2023, 1, 1))
      expect(loaded_record.period_end).to eq(Strata::USDate.new(2023, 12, 31))
    end
  end
end
