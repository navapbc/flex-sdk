# frozen_string_literal: true

class AddFieldsToTestApplicationForms < ActiveRecord::Migration[8.0]
  def change
    add_column :test_application_forms, :applicant_name_first, :string
    add_column :test_application_forms, :applicant_name_middle, :string
    add_column :test_application_forms, :applicant_name_last, :string
    add_column :test_application_forms, :applicant_name_suffix, :string
    add_column :test_application_forms, :mailing_address_street_line_1, :string
    add_column :test_application_forms, :mailing_address_street_line_2, :string
    add_column :test_application_forms, :mailing_address_city, :string
    add_column :test_application_forms, :mailing_address_state, :string
    add_column :test_application_forms, :mailing_address_zip_code, :string
    add_column :test_application_forms, :date_of_birth, :date
    add_column :test_application_forms, :salary, :integer
    add_column :test_application_forms, :ssn, :string
    add_column :test_application_forms, :hire_date, :date
    add_column :test_application_forms, :leave_type, :integer
    add_column :test_application_forms, :reviewed, :boolean
    add_column :test_application_forms, :start_date, :date
    add_column :test_application_forms, :notes, :text
    add_column :test_application_forms, :age, :integer
    add_column :test_application_forms, :employer_name, :string
  end
end
