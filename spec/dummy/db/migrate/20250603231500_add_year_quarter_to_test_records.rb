class AddYearQuarterToTestRecords < ActiveRecord::Migration[8.0]
  def change
    add_column :test_records, :reporting_period_year, :integer
    add_column :test_records, :reporting_period_quarter, :integer
  end
end
