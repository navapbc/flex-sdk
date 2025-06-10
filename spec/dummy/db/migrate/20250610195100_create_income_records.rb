class CreateIncomeRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :income_records do |t|
      t.integer :period_year
      t.integer :period_quarter

      t.timestamps
    end
  end
end
