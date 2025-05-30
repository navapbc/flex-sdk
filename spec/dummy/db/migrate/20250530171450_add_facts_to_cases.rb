class AddFactsToCases < ActiveRecord::Migration[8.0]
  def change
    add_column :passport_cases, :facts, :jsonb, default: '{}'
    add_column :test_cases, :facts, :jsonb, default: '{}'
  end
end
