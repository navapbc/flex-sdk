# frozen_string_literal: true

class RefactorYearQuarterYearMonthToSingleColumns < ActiveRecord::Migration[8.0]
  def change
    # Remove old separate integer columns
    remove_column :test_records, :reporting_period_year, :integer
    remove_column :test_records, :reporting_period_quarter, :integer
    remove_column :test_records, :activity_reporting_period_year, :integer
    remove_column :test_records, :activity_reporting_period_month, :integer
    remove_column :test_records, :base_period_start_year, :integer
    remove_column :test_records, :base_period_start_quarter, :integer
    remove_column :test_records, :base_period_end_year, :integer
    remove_column :test_records, :base_period_end_quarter, :integer

    # Add new single string columns
    add_column :test_records, :reporting_period, :string
    add_column :test_records, :activity_reporting_period, :string
    add_column :test_records, :base_period_start, :string
    add_column :test_records, :base_period_end, :string
  end
end
