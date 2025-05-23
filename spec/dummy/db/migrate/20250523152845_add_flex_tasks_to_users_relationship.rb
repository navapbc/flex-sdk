class AddFlexTasksToUsersRelationship < ActiveRecord::Migration[8.0]
  def change
    add_foreign_key :flex_tasks, :users, column: :assignee_id, primary_key: :id, on_delete: :nullify
  end
end
