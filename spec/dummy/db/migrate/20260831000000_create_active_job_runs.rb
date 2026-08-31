# frozen_string_literal: true

class CreateActiveJobRuns < ActiveRecord::Migration[8.0]
  def change
    create_table :active_job_runs, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :job_id, null: false
      t.string :job_class, null: false
      t.string :queue_name, null: false
      t.string :status, null: false
      t.integer :executions, null: false, default: 1
      t.jsonb :arguments, null: false, default: []
      t.datetime :enqueued_at
      t.datetime :started_at, null: false
      t.datetime :finished_at
      t.integer :duration_ms
      t.string :error_class
      t.text :error_message

      t.timestamps
    end

    add_index :active_job_runs, :job_id
    add_index :active_job_runs, [ :job_id, :executions ], unique: true
    add_index :active_job_runs, :started_at
    add_index :active_job_runs, [ :status, :started_at ]
  end
end
