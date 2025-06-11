class AddArraysToTestRecords < ActiveRecord::Migration[8.0]
  def change
    add_column :test_records, :addresses, :jsonb
    add_column :test_records, :names, :jsonb
    add_column :test_records, :reporting_periods, :jsonb
  end
end
