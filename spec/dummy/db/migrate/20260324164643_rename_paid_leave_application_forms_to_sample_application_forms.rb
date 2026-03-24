# frozen_string_literal: true

class RenamePaidLeaveApplicationFormsToSampleApplicationForms < ActiveRecord::Migration[8.0]
  def change
    rename_table :paid_leave_application_forms, :sample_application_forms
  end
end
