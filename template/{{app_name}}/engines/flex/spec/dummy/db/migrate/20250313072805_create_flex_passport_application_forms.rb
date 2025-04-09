class CreateFlexPassportApplicationForms < ActiveRecord::Migration[8.0]
  def change
    create_table :flex_passport_application_forms do |t|
      t.string :first_name
      t.string :last_namen
      t.date :date_of_birth
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
