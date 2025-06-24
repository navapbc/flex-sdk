class RenameDateRangeColumnsToPeriod < ActiveRecord::Migration[8.0]
  def change
    rename_column :test_records, :date_range_start, :period_start
    rename_column :test_records, :date_range_end, :period_end
  end
end
