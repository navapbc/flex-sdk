# frozen_string_literal: true

class AddNameSuffixToPassportApplicationForms < ActiveRecord::Migration[8.0]
  def change
    add_column :passport_application_forms, :name_suffix, :string
  end
end
