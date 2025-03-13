class CreateFlexBusinessExclusionForms < ActiveRecord::Migration[8.0]
  def change
    create_table :flex_business_exclusion_forms do |t|
      t.string :business_name
      t.text :business_type
      t.integer :status, default: 0

      t.timestamps
    end
    add_index :flex_business_exclusion_forms, :business_name, unique: true
  end
end
