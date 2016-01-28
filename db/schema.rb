# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160128174704) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "users", force: :cascade do |t|
    t.string   "provider",               default: "email", null: false
    t.string   "uid",                    default: "",      null: false
    t.string   "encrypted_password",     default: "",      null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,       null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0,       null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "name"
    t.string   "nickname"
    t.string   "image"
    t.string   "email"
    t.json     "tokens"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "world_surveys", force: :cascade do |t|
    t.string   "system"
    t.string   "commander"
    t.string   "world"
    t.string   "world_type"
    t.float    "gravity"
    t.integer  "terrain_difficulty"
    t.text     "notes"
    t.boolean  "carbon"
    t.boolean  "iron"
    t.boolean  "nickel"
    t.boolean  "phosphorus"
    t.boolean  "sulphur"
    t.boolean  "arsenic"
    t.boolean  "chromium"
    t.boolean  "germanium"
    t.boolean  "manganese"
    t.boolean  "selenium"
    t.boolean  "vanadium"
    t.boolean  "zinc"
    t.boolean  "zirconium"
    t.boolean  "cadmium"
    t.boolean  "mercury"
    t.boolean  "molybdenum"
    t.boolean  "niobium"
    t.boolean  "tin"
    t.boolean  "tungsten"
    t.boolean  "antimony"
    t.boolean  "polonium"
    t.boolean  "ruthenium"
    t.boolean  "technetium"
    t.boolean  "tellurium"
    t.boolean  "yttrium"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.float    "arrival_point"
    t.float    "radius"
    t.string   "terraformable",      limit: 30
    t.string   "vulcanism_type",     limit: 30
    t.string   "atmosphere_type",    limit: 30
    t.string   "reserve"
    t.float    "mass"
    t.integer  "surface_temp"
    t.float    "surface_pressure"
    t.float    "orbit_period"
    t.float    "rotation_period"
    t.float    "semi_major_axis"
    t.float    "rock_pct"
    t.float    "metal_pct"
    t.float    "ice_pct"
  end

  add_index "world_surveys", ["commander"], name: "index_world_surveys_on_commander", using: :btree
  add_index "world_surveys", ["system", "commander", "world", "updated_at"], name: "index_world_surveys_on_sys_com_wor_upd", using: :btree
  add_index "world_surveys", ["system"], name: "index_world_surveys_on_system", using: :btree
  add_index "world_surveys", ["updated_at"], name: "index_world_surveys_on_updated_at", using: :btree
  add_index "world_surveys", ["world"], name: "index_world_surveys_on_world", using: :btree

end
