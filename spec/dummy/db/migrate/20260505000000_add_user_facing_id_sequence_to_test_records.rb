# frozen_string_literal: true

class AddUserFacingIdSequenceToTestRecords < ActiveRecord::Migration[8.0]
  def change
    add_column :test_records, :user_facing_id_sequence, :bigint
    add_index :test_records, :user_facing_id_sequence, unique: true
  end
end
