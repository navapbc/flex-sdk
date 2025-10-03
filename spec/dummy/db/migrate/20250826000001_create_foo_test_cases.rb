# frozen_string_literal: true

class CreateFooTestCases < ActiveRecord::Migration[8.0]
  def change
    create_table :foo_test_cases, id: :uuid do |t|
      t.integer :status, default: 0
      t.string :business_process_current_step
      t.uuid :application_form_id
      t.jsonb :facts, default: {}

      t.timestamps
    end
  end
end
