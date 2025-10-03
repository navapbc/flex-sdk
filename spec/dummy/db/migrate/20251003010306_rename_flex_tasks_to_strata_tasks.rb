class RenameFlexTasksToStrataTasks < ActiveRecord::Migration[8.0]
  def change
    rename_table :flex_tasks, :strata_tasks
  end
end
