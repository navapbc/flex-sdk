class CreateFlexPassportCases < ActiveRecord::Migration[8.0]
  def change
    create_table :flex_passport_cases do |t|
      t.string :passport_id, null: false, unique: true, default: -> { "gen_random_uuid()" }
      t.integer :status, default: 0, null: false

      t.timestamps
    end
  end
end
