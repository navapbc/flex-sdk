class CreatePassportCases < ActiveRecord::Migration[8.0]
  def change
    create_table :passport_cases do |t|
      t.integer :status, default: 0, null: false
      t.string :passport_id, null: false
      t.string :business_process_current_step

      t.timestamps
    end

    add_index :passport_application_forms, :case_id, unique: true
    add_foreign_key :passport_application_forms, :passport_cases, column: :case_id, primary_key: :id, on_delete: :cascade
  end
end
