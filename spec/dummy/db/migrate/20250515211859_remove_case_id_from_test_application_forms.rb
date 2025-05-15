class RemoveCaseIdFromTestApplicationForms < ActiveRecord::Migration[8.0]
  def change
    remove_column :test_application_forms, :case_id, :string
  end
end
