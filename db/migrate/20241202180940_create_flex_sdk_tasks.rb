# class CreateFlexSdkTasks < ActiveRecord::Migration[8.0]
#   def change
#     create_table :flex_sdk_tasks do |t|
#       t.references :business_processes, null: false, foreign_key: {to_table: :flex_sdk_business_process}
#       t.string :type
#       t.timestamps
#     end
#   end
# end
