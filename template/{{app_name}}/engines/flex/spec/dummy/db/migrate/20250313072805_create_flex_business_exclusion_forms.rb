class CreateFlexTestExclusionForms < ActiveRecord::Migration[8.0]
  def change
    create_table :flex_test_exclusion_forms do |t|
      t.string :business_name
      t.text :business_type
      t.integer :status, default: 0

      t.timestamps
    end
    add_index :flex_test_exclusion_forms, :business_name, unique: true
  end
end
