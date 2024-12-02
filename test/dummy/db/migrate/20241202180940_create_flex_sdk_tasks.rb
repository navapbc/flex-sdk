class CreateFlexSdkTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :flex_sdk_tasks do |t|
      t.references :flex_sdk_business_process, null: false, foreign_key: true
      t.string :type
      t.timestamps
    end
  end
end
