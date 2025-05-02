class CreateTestTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :tasks do |t|
    t.string :type, index: true
    t.text :description
    t.belongs_to :assignee, null: true, index: true, polymorphic: true
    t.string :status, index: true

    t.timestamps
    end
  end

  create_table :users do |t|
    t.string :name

    t.timestamps
  end
end
