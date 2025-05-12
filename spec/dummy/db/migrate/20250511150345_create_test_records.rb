class CreateTestRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :test_records do |t|
      t.date :date_of_birth

      t.timestamps
    end
  end
end
