# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_05_24_153302) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cases", force: :cascade do |t|
    t.bigint "municipality_id", null: false
    t.datetime "day", null: false
    t.integer "reports"
    t.integer "hospitalizations"
    t.integer "deaths"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "new_reports"
    t.boolean "processed", default: false, null: false
    t.index ["municipality_id", "day"], name: "index_cases_on_municipality_id_and_day", unique: true
    t.index ["municipality_id"], name: "index_cases_on_municipality_id"
  end

  create_table "municipalities", force: :cascade do |t|
    t.bigint "province_id", null: false
    t.string "cbs_id", null: false
    t.string "name", null: false
    t.integer "inhabitants", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "position"
    t.string "slug"
    t.index ["cbs_id"], name: "index_municipalities_on_cbs_id", unique: true
    t.index ["province_id"], name: "index_municipalities_on_province_id"
    t.index ["slug"], name: "index_municipalities_on_slug", unique: true
  end

  create_table "provinces", force: :cascade do |t|
    t.integer "cbs_n"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "position"
    t.string "slug"
    t.index ["slug"], name: "index_provinces_on_slug", unique: true
  end

  add_foreign_key "cases", "municipalities"
  add_foreign_key "municipalities", "provinces"
end
