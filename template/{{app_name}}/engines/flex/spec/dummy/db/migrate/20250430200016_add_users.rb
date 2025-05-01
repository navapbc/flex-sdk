class AddUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string :name

      t.timestamps
    end

    add_foreign_key :tasks, :users, column: :assignee_id, primary_key: :id, on_delete: :nullify
  end
end
