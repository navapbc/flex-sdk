class RemoveTasksCaseTypeCaseIdIndex < ActiveRecord::Migration[8.0]
  def change
    remove_index :flex_tasks, [ :case_id, :case_type ]
    add_index :flex_tasks, [ :case_id ]
    add_index :flex_tasks, [ :case_type ]
  end
end
