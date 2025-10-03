# frozen_string_literal: true

class AddTaxIdToTestRecords < ActiveRecord::Migration[8.0]
  def change
    add_column :test_records, :tax_id, :string
  end
end
