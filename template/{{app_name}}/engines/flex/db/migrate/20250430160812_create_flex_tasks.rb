class CreateFlexTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :flex_tasks do |t|
    t.string :type, index: true
    t.text :description
    t.uuid :assignee_id, index: true
    t.integer :status, index: true, default: 0

    t.timestamps
    end
  end
end
