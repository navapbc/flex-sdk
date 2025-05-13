class ChangeTestCasesIdToStringUuid < ActiveRecord::Migration[8.0]
  def change
    # Change the ID column of the test_cases table to a string UUID
    reversible do |dir|
      dir.up do
        # You'll need to truncate your table before changing the column type
        change_column :test_cases, :id, :string, limit: 36, null: false, default: -> { "uuid_generate_v4()" }
      end

      dir.down do
        change_column :test_cases, :id, :integer, null: false
      end
    end
  end
end
