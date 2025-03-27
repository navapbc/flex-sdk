class CreateFlexPassportCases < ActiveRecord::Migration[8.0]
  def change
    create_table :flex_passport_cases do |t|
      t.integer :status, default: 0, null: false
      t.integer :passportId, null: false

      t.timestamps
    end
  end
end
