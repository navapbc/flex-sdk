# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2024_12_02_180940) do
  create_table :flex_passport_application_forms, force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.date "date_of_birth"
    t.integer "status", default: 0

    t.timestamps
  end

  create_table :flex_passport_cases do |t|
    t.integer :status, default: 0, null: false
    t.string :passport_id, null: false, limit: 36 # Is a UUID, which is always exactly 36 characters
    t.integer :passport_application_form_id
    t.string :business_process_current_step
    t.references :flex_passport_application_forms, type: :integer, foreign_key: true

    t.timestamps
  end

  add_index :flex_passport_cases, :passport_application_form_id, unique: true
  add_foreign_key "flex_passport_cases", "flex_passport_application_forms", column: "passport_application_form_id", name: "fk_passport_application_forms"
end
