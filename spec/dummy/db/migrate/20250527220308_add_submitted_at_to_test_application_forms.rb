class AddSubmittedAtToTestApplicationForms < ActiveRecord::Migration[8.0]
  def change
    add_column :test_application_forms, :submitted_at, :datetime

    # Backfill data for existing submitted forms
    execute <<-SQL
      UPDATE test_application_forms
      SET submitted_at = updated_at
      WHERE status = 1
    SQL
  end
end
