class UpdateNameFieldsInPassportApplicationForms < ActiveRecord::Migration[8.0]
  def change
    rename_column :passport_application_forms, :first_name, :name_first
    rename_column :passport_application_forms, :last_name, :name_last
    add_column :passport_application_forms, :name_middle, :string
  end
end
