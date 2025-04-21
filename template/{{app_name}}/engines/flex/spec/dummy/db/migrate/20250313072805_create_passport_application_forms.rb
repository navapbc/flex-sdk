class CreateFlexPassportApplicationForms < ActiveRecord::Migration[8.0]
  def change
    create_table :passport_application_forms do |t|
      t.string :first_name
      t.string :last_name
      t.date :date_of_birth
      t.integer :status, default: 0
      t.integer :case_id

      t.timestamps
    end
  end
end
