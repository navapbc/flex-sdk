class RemoveCaseIdFromPassportApplicationForms < ActiveRecord::Migration[8.0]
  def change
    remove_column :passport_application_forms, :case_id, :string
  end
end
