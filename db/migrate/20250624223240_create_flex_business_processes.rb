class CreateFlexBusinessProcesses < ActiveRecord::Migration[8.0]
  def change
    create_table :flex_business_processes do |t|
      t.string :type, index: true
      t.uuid :case_id, index: true
      t.string :case_type
      t.string :current_step

      t.timestamps
    end

    # TODO migrate current_step from cases tables in dummy apps
  end
end
