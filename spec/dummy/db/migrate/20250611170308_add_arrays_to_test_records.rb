# frozen_string_literal: true

class AddArraysToTestRecords < ActiveRecord::Migration[8.0]
  def change
    add_column :test_records, :addresses, :jsonb
    add_column :test_records, :leave_periods, :jsonb
    add_column :test_records, :names, :jsonb
    add_column :test_records, :reporting_periods, :jsonb
  end
end
