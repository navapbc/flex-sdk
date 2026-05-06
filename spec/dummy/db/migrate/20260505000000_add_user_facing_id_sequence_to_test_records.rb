# frozen_string_literal: true

class AddUserFacingIdSequenceToTestRecords < ActiveRecord::Migration[8.0]
  SEQUENCE_NAME = "test_records_user_facing_id_sequence_seq"

  def up
    execute "CREATE SEQUENCE #{SEQUENCE_NAME} AS bigint"

    add_column :test_records, :user_facing_id_sequence, :bigint,
      default: -> { "nextval('#{SEQUENCE_NAME}')" },
      null: false
    add_index :test_records, :user_facing_id_sequence, unique: true

    execute "ALTER SEQUENCE #{SEQUENCE_NAME} OWNED BY test_records.user_facing_id_sequence"
  end

  def down
    remove_index :test_records, :user_facing_id_sequence
    remove_column :test_records, :user_facing_id_sequence

    execute "DROP SEQUENCE IF EXISTS #{SEQUENCE_NAME}"
  end
end
