# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20201228032354) do

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string "note"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "overtime_end_plan"
    t.string "next_day_check", default: "0"
    t.string "overtime_detail"
    t.integer "overtime_superior_id"
    t.string "overtime_status"
    t.integer "overtime_approval", default: 1
    t.string "overtime_check", default: "0"
    t.string "overtime_hour"
    t.string "overtime_superior_name"
    t.datetime "change_started_at"
    t.datetime "change_finished_at"
    t.string "change_next_day_check"
    t.string "change_note"
    t.string "change_status"
    t.integer "change_approval", default: 1
    t.integer "change_superior_id"
    t.string "change_superior_name"
    t.string "change_check"
    t.integer "one_month_apply_superior_id"
    t.integer "one_month_approval", default: 1
    t.string "one_month_status"
    t.string "one_month_check", default: "0"
    t.string "one_month_superior_name"
    t.datetime "change_date"
    t.date "calendar_day"
    t.date "search_day"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "bases", force: :cascade do |t|
    t.integer "base_number"
    t.string "base_name"
    t.string "base_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.boolean "admin", default: false
    t.string "affiliation"
    t.integer "employee_number"
    t.datetime "basic_work_time", default: "2021-01-03 23:00:00"
    t.datetime "designated_work_start_time", default: "2021-01-03 22:30:00"
    t.datetime "designated_work_end_time", default: "2021-01-04 09:00:00"
    t.string "uid"
    t.boolean "superior", default: false
    t.string "remember_digest"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
