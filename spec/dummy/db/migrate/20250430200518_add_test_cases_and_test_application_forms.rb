class AddTestCasesAndTestApplicationForms < ActiveRecord::Migration[8.0]
  def change
    create_table :test_application_forms, id: :uuid do |t|
      t.integer :status, default: 0
      t.string :test_string

      t.timestamps
    end

    create_table :test_cases, id: :uuid do |t|
      t.integer :status, default: 0, null: false
      t.string :business_process_current_step

      t.timestamps
    end
  end
end
