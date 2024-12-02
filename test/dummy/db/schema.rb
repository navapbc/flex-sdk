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
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "flex_sdk_business_processes", force: :cascade do |t|
    t.bigint "application_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["application_id"], name: "index_flex_sdk_business_processes_on_application_id"
  end

  create_table "flex_sdk_paid_leave_applications", force: :cascade do |t|
    t.string "applicant_id"
    t.string "applicant_first_name", null: false
    t.string "applicant_middle_name"
    t.string "applicant_last_name", null: false
    t.string "applicant_email"
    t.string "applicant_phone"
    t.string "leave_type", null: false
    t.date "applicant_date_of_birth"
    t.string "status", default: "in_progress", null: false
    t.datetime "submitted_at"
    t.string "program_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "flex_sdk_tasks", force: :cascade do |t|
    t.bigint "flex_sdk_business_process_id", null: false
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["flex_sdk_business_process_id"], name: "index_flex_sdk_tasks_on_flex_sdk_business_process_id"
  end

  add_foreign_key "flex_sdk_business_processes", "flex_sdk_paid_leave_applications", column: "application_id"
  add_foreign_key "flex_sdk_tasks", "flex_sdk_business_processes"
end
