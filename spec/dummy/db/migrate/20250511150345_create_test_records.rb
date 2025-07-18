class CreateTestRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :test_records, id: :uuid do |t|
      t.date :date_of_birth

      t.timestamps
    end
  end
end
