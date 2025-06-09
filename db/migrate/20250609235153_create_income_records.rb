class CreateIncomeRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :income_records do |t|
      t.string :person_id
      t.integer :amount
      t.integer :period_year
      t.integer :period_quarter
      t.date :period_start
      t.date :period_end

      t.timestamps
    end
  end
end
