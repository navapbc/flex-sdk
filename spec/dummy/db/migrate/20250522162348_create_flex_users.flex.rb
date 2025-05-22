# This migration comes from flex (originally 20250508184707)
class CreateFlexUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :flex_users do |t|
      t.string :first_name
      t.string :last_name

      t.timestamps
    end

    add_foreign_key :flex_tasks, :flex_users, column: :assignee_id, primary_key: :id, on_delete: :nullify
  end
end
