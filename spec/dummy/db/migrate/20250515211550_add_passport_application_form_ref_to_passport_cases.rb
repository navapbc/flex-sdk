class AddPassportApplicationFormRefToPassportCases < ActiveRecord::Migration[8.0]
  def change
    execute "DELETE FROM passport_cases"
    add_reference :passport_cases, :application_form, type: :string, null: false, foreign_key: { to_table: :passport_application_forms }
  end
end
