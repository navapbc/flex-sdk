class AddDateRangeToTestRecords < ActiveRecord::Migration[8.0]
  def change
    add_column :test_records, :date_range_start, :date
    add_column :test_records, :date_range_end, :date
  end
end
