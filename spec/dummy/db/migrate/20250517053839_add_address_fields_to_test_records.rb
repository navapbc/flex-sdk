# frozen_string_literal: true

class AddAddressFieldsToTestRecords < ActiveRecord::Migration[8.0]
  def change
    add_column :test_records, :address_street_line_1, :string
    add_column :test_records, :address_street_line_2, :string
    add_column :test_records, :address_city, :string
    add_column :test_records, :address_state, :string
    add_column :test_records, :address_zip_code, :string
  end
end
