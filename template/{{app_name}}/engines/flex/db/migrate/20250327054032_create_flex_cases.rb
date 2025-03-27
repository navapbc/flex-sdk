class CreateFlexCases < ActiveRecord::Migration[8.0]
  def change
    create_table :flex_cases do |t|
      t.integer :status, default: 0, null: false

      t.timestamps
    end
  end
end
