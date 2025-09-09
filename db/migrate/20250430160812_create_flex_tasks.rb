class CreateFlexTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :flex_tasks, id: :uuid do |t|
    t.string :type, index: true
    t.text :description
    t.integer :status, index: true, default: 0
    t.uuid :assignee_id, index: true # not linked to anything yet but will be later
    t.uuid :case_id, index: true
    t.string :case_type
    t.date :due_on

    t.timestamps
    end
  end
end
