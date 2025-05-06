class AddDueOnColumnToFlexTasks < ActiveRecord::Migration[8.0]
  def change
    add_column :flex_tasks, :due_on, :date
  end
end
