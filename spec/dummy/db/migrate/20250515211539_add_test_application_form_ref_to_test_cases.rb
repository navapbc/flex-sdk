class AddTestApplicationFormRefToTestCases < ActiveRecord::Migration[8.0]
  def change
    add_reference :test_cases, :application_form, type: :string
  end
end
