# class CreateFlexSdkPaidLeaveApplications < ActiveRecord::Migration[8.0]
#   def change
#     create_table :flex_sdk_paid_leave_applications do |t|
#       t.string :applicant_id
#       t.string :applicant_first_name, null: false
#       t.string :applicant_middle_name
#       t.string :applicant_last_name, null: false
#       t.string :applicant_email
#       t.string :applicant_phone
#       t.string :leave_type, null: false

#       t.date :applicant_date_of_birth
#       t.string :status, default: 'in_progress', null: false
#       t.datetime :submitted_at
#       t.string :program_type
#       t.timestamps
#     end
#   end
# end
