class RemoveTasksCaseTypeCaseIdIndex < ActiveRecord::Migration[8.0]
  def change
    remove_index :strata_tasks, [ :case_id, :case_type ]
    add_index :strata_tasks, [ :case_id ]
  end
end
