# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string :first_name
      t.string :last_name

      t.timestamps
    end
  end
end
