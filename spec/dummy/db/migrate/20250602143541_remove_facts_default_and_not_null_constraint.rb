class RemoveFactsDefaultAndNotNullConstraint < ActiveRecord::Migration[8.0]
  def change
    # Remove the default value and NOT NULL constraint from the facts column in passport_cases
    change_column_default :passport_cases, :facts, from: {}, to: nil
    change_column_null :passport_cases, :facts, true

    # Remove the default value and NOT NULL constraint from the facts column in test_cases
    change_column_default :test_cases, :facts, from: {}, to: nil
    change_column_null :test_cases, :facts, true
  end
end
