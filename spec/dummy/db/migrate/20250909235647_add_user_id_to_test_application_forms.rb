# frozen_string_literal: true

class AddUserIdToTestApplicationForms < ActiveRecord::Migration[8.0]
  def change
    add_column :test_application_forms, :user_id, :uuid
  end
end
