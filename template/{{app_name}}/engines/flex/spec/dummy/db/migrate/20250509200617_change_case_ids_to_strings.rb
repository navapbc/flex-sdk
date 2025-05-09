class ChangeCaseIdsToStrings < ActiveRecord::Migration[8.0]
  def change
    reversible do |dir|
      dir.up do
        change_column :passport_application_forms, :case_id, :string, limit: 36, null: false
        change_column :passport_cases, :id, :string, limit: 36, default: -> { "uuid_generate_v4()" }, primary_key: true
      end

      dir.down do
        change_column :passport_application_forms, :case_id, :integer
        change_column :passport_cases, :id, :integer, primary_key: true
      end
    end
  end
end
# This is temporary