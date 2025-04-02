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

ActiveRecord::Schema[8.0].define(version: 2025_04_01_120000) do
  create_table "flex_passport_application_forms", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.date "date_of_birth", null: false
    t.integer "status", default: 0

    t.timestamps
  end

  create_table :flex_passport_cases do |t|
    t.string :passport_id, null: false, unique: true, default: -> { "gen_random_uuid()" }
    t.integer :status, default: 0, null: false
    t.integer :passport_application_form_id, null: false
    t.index :flex_passport_cases, :passport_application_form_id, unique: true
    t.foreign_key :flex_passport_application_forms, column: :passport_application_form_id
    
    t.timestamps
  end


  create_table "flex_business_processes", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "status", default: 0, null: false
    t.string "type"
    t.bigint "case_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["case_id"], name: "index_flex_business_processes_on_case_id"
    t.foreign_key "flex_passport_cases", column: "case_id"

    t.timestamps
  end
end
