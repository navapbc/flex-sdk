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

ActiveRecord::Schema[8.0].define(version: 2025_04_29_160812) do
  enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")
  enable_extension "plpgsql" unless extension_enabled?("plpgsql")
  create_table :flex_tasks, id: :uuid do |t|
    t.string :type, index: true
    t.text :description
    t.uuid :assignee_id, index: true
    t.integer :status, index: true, default: 0

    t.timestamps
  end
end
