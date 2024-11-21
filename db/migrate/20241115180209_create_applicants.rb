class CreateApplicants < ActiveRecord::Migration[8.0]
  def change
    create_table :applicants do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :social_security_number, null: true
      t.string :phone_number, null: true

      t.timestamps
    end

    add_index :applicants, :social_security_number, unique: true
  end
end
