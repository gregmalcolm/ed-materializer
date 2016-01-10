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

ActiveRecord::Schema.define(version: 20160110151113) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "world_surveys", force: :cascade do |t|
    t.string   "system"
    t.string   "commander"
    t.string   "world"
    t.string   "world_type"
    t.boolean  "terraformable"
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
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.float    "arrival_point"
    t.integer  "atmosphere_type"
    t.integer  "vulcanism_type"
    t.float    "radius"
  end

  add_index "world_surveys", ["commander"], name: "index_world_surveys_on_commander", using: :btree
  add_index "world_surveys", ["system", "commander", "world", "updated_at"], name: "index_world_surveys_on_sys_com_wor_upd", using: :btree
  add_index "world_surveys", ["system"], name: "index_world_surveys_on_system", using: :btree
  add_index "world_surveys", ["updated_at"], name: "index_world_surveys_on_updated_at", using: :btree
  add_index "world_surveys", ["world"], name: "index_world_surveys_on_world", using: :btree

end
