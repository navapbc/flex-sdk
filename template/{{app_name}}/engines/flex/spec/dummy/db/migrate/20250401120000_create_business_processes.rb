class CreateBusinessProcesses < ActiveRecord::Migration[8.0]
  def change
    create_table :flex_business_processes do |t|
      t.string :name, null: false
      t.text :description
      t.integer :status, default: 0, null: false
      t.string :type # For Single Table Inheritance (STI)
      t.string :current_step
      t.references :case, null: false, foreign_key: { to_table: :flex_passport_cases }

      t.timestamps
    end
  end
end
