class AddPassportApplicationFormIdToFlexPassportCases < ActiveRecord::Migration[8.0]
  def change
    add_column :flex_passport_cases, :passport_application_form_id, :integer, null: false
    add_foreign_key :flex_passport_cases, :flex_passport_application_forms, column: :passport_application_form_id
    add_index :flex_passport_cases, :passport_application_form_id, unique: true
  end
end
