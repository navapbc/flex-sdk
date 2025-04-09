class CreateFlexPassportCases < ActiveRecord::Migration[8.0]
  def change
    create_table :flex_passport_cases do |t|
      t.integer :status, default: 0, null: false
      t.string :passport_id, null: false, limit: 36 # Is a UUID, which is always exactly 36 characters
      t.string :business_process_current_step

      t.timestamps
    end

    add_index :flex_passport_application_forms, :case_id, unique: true
    add_foreign_key :flex_passport_application_forms, :flex_passport_cases, column: :case_id, primary_key: :id, on_delete: :cascade
  end
end
