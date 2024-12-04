class CreateFlexSdkBusinessProcesses < ActiveRecord::Migration[8.0]
    def change
      create_table "flex_sdk_business_processes", force: :cascade do |t|
        t.string "type" # For STI, storing class names like "PaidLeaveApplicationBusinessProcess"
        t.bigint "application_id", null: false
        t.timestamps
  
      # create_table :flex_sdk_business_processes do |t|
      #   t.references :application, null: false, foreign_key: { to_table: :flex_sdk_paid_leave_applications}
      #   t.timestamps
      end
    end
  end
  
  