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

ActiveRecord::Schema[8.0].define(version: 2025_05_30_171450) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "flex_tasks", force: :cascade do |t|
    t.string "type"
    t.text "description"
    t.integer "status", default: 0
    t.integer "assignee_id"
    t.integer "case_id"
    t.date "due_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignee_id"], name: "index_flex_tasks_on_assignee_id"
    t.index ["case_id"], name: "index_flex_tasks_on_case_id"
    t.index ["status"], name: "index_flex_tasks_on_status"
    t.index ["type"], name: "index_flex_tasks_on_type"
  end

  create_table "passport_application_forms", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.date "date_of_birth"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "submitted_at"
  end

  create_table "passport_cases", force: :cascade do |t|
    t.integer "status", default: 0, null: false
    t.string "passport_id", null: false
    t.string "business_process_current_step"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "application_form_id"
    t.jsonb "facts", default: "{}", null: false
    t.index ["application_form_id"], name: "index_passport_cases_on_application_form_id"
  end

  create_table "test_application_forms", force: :cascade do |t|
    t.integer "status", default: 0
    t.string "test_string"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "submitted_at"
  end

  create_table "test_cases", force: :cascade do |t|
    t.integer "status", default: 0, null: false
    t.string "business_process_current_step"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "application_form_id"
    t.jsonb "facts", default: "{}", null: false
    t.index ["application_form_id"], name: "index_test_cases_on_application_form_id"
  end

  create_table "test_records", force: :cascade do |t|
    t.date "date_of_birth"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name_first"
    t.string "name_middle"
    t.string "name_last"
    t.string "address_street_line_1"
    t.string "address_street_line_2"
    t.string "address_city"
    t.string "address_state"
    t.string "address_zip_code"
    t.string "tax_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "flex_tasks", "users", column: "assignee_id", on_delete: :nullify
end
