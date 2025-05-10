class CreateTestRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :test_records do |t|
      t.date :period_start
      t.date :period_end

      t.timestamps
    end
  end
end
