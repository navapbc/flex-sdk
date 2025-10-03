# frozen_string_literal: true

class AddYearQuarterRangeToTestRecords < ActiveRecord::Migration[8.0]
  def change
    add_column :test_records, :base_period_start_year, :integer
    add_column :test_records, :base_period_start_quarter, :integer
    add_column :test_records, :base_period_end_year, :integer
    add_column :test_records, :base_period_end_quarter, :integer
  end
end
