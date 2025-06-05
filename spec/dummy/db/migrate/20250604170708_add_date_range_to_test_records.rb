class AddDateRangeToTestRecords < ActiveRecord::Migration[8.0]
  def change
    add_column :test_records, :period_start, :date
    add_column :test_records, :period_end, :date
  end
end
