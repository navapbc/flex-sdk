class AddUSDateToTestRecords < ActiveRecord::Migration[8.0]
  def change
    add_column :test_records, :adopted_on, :date
  end
end
