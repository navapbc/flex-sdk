# frozen_string_literal: true

class CreatePaidLeaveApplicationForms < ActiveRecord::Migration[8.0]
  def change
    create_table :paid_leave_application_forms do |t|
      t.uuid :user_id
      t.integer :status
      t.datetime :submitted_at
      t.string :applicant_name_first
      t.date :date_of_birth
      t.string :employer_name
      t.string :leave_type

      t.timestamps
    end
  end
end
