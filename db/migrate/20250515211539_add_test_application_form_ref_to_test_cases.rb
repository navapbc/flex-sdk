class AddTestApplicationFormRefToTestCases < ActiveRecord::Migration[8.0]
  def change
    execute "DELETE FROM test_cases"
    add_reference :test_cases, :application_form, type: :string, null: false, foreign_key: { to_table: :test_application_forms }
  end
end
