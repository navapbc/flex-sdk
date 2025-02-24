class CreateUserRoles < ActiveRecord::Migration[7.1]
  def change
    create_table :user_roles, id: :uuid do |t|
      t.references "user", type: :uuid, null: false, foreign_key: true
      t.integer "role", null: false

      t.timestamps
    end
  end
end
