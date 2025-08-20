class AddYearMonthToTestRecords < ActiveRecord::Migration[8.0]
  def change
    add_column :test_records, :activity_reporting_period_year, :integer
    add_column :test_records, :activity_reporting_period_month, :integer
    add_column :test_records, :activity_reporting_periods, :jsonb
  end
end
