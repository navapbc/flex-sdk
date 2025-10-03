# frozen_string_literal: true

class AddFactsToCases < ActiveRecord::Migration[8.0]
  def change
    add_column :passport_cases, :facts, :jsonb, default: '{}', null: false
    add_column :test_cases, :facts, :jsonb, default: '{}', null: false
  end
end
