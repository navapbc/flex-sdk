class CreateFlexTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :flex_tasks do |t|
    t.string :type, index: true
    t.text :description
    t.integer :status, index: true, default: 0
    t.string :assignee_id, index: true # not linked to anything yet but will be later
    t.string :case_id, index: true

    t.timestamps
    end
  end
end
