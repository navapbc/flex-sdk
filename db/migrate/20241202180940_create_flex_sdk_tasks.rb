class CreateFlexSdkTasks < ActiveRecord::Migration[8.0]
    def change
      create_table "flex_sdk_tasks", force: :cascade do |t|
        t.string "type" # For STI, storing class names like "FindEmploymentRecordTask"
        t.bigint "business_process_id", null: false # Foreign key linking to "flex_sdk_business_processes"
        t.timestamps
  
        # t.references :flex_sdk_business_process, null: false, foreign_key: true
        # t.string :type
        # t.timestamps
      end
    end
  end
  