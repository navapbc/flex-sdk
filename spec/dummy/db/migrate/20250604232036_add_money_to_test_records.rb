class AddMoneyToTestRecords < ActiveRecord::Migration[8.0]
  def change
    add_column :test_records, :money, :integer
  end
end
