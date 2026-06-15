# frozen_string_literal: true

class CreateLeaveRequestApplicationForms < ActiveRecord::Migration[8.0]
  def change
    create_table :leave_request_application_forms do |t|
      t.uuid :user_id
      t.integer :status
      t.datetime :submitted_at
      t.string :first_name
      t.string :last_name
      t.date :date_of_birth
      t.string :street_address
      t.string :zip_code

      t.timestamps
    end
  end
end
