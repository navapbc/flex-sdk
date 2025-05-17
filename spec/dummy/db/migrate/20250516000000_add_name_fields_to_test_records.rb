class AddNameFieldsToTestRecords < ActiveRecord::Migration[8.0]
  def change
    add_column :test_records, :name_first, :string
    add_column :test_records, :name_middle, :string
    add_column :test_records, :name_last, :string
  end
end
