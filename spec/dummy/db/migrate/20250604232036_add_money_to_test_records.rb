# frozen_string_literal: true

class AddMoneyToTestRecords < ActiveRecord::Migration[8.0]
  def change
    add_column :test_records, :weekly_wage, :integer
  end
end
