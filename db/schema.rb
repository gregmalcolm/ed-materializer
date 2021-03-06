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

ActiveRecord::Schema.define(version: 20160523163132) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "basecamps", force: :cascade do |t|
    t.integer  "world_id"
    t.string   "updater",              limit: 50
    t.string   "name",                 limit: 50
    t.text     "description"
    t.string   "landing_zone_terrain", limit: 30
    t.integer  "terrain_hue_1"
    t.integer  "terrain_hue_2"
    t.integer  "terrain_hue_3"
    t.float    "landing_zone_lat"
    t.float    "landing_zone_lon"
    t.text     "notes"
    t.string   "image_url"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "updaters",                                                     array: true
    t.string   "ed_version"
    t.boolean  "numeric",                         default: false, null: false
  end

  add_index "basecamps", ["updated_at"], name: "index_basecamps_on_updated_at", using: :btree
  add_index "basecamps", ["updater"], name: "index_basecamps_on_updater", using: :btree
  add_index "basecamps", ["updaters"], name: "index_basecamps_on_updaters", using: :gin
  add_index "basecamps", ["world_id", "updater", "updated_at"], name: "index_basecamps_on_wor_updr_upd", using: :btree
  add_index "basecamps", ["world_id"], name: "index_basecamps_on_world_id", using: :btree

  create_table "stars", force: :cascade do |t|
    t.string   "system_name",       limit: 50
    t.string   "updater",           limit: 50
    t.string   "star",              limit: 50
    t.string   "spectral_class"
    t.string   "spectral_subclass"
    t.float    "solar_mass"
    t.float    "solar_radius"
    t.float    "star_age"
    t.float    "orbit_period"
    t.float    "arrival_point"
    t.string   "luminosity"
    t.text     "notes"
    t.integer  "surface_temp"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "image_url"
    t.string   "updaters",                                  array: true
    t.integer  "system_id"
  end

  add_index "stars", ["star"], name: "index_stars_on_star", using: :btree
  add_index "stars", ["system_id"], name: "index_stars_on_system_id", using: :btree
  add_index "stars", ["system_name", "star", "updated_at"], name: "index_stars_on_sys_sta_upd", using: :btree
  add_index "stars", ["system_name"], name: "index_stars_on_system_name", using: :btree
  add_index "stars", ["updated_at"], name: "index_stars_on_updated_at", using: :btree
  add_index "stars", ["updater"], name: "index_stars_on_updater", using: :btree
  add_index "stars", ["updaters"], name: "index_stars_on_updaters", using: :gin

  create_table "surveys", force: :cascade do |t|
    t.integer  "basecamp_id"
    t.string   "commander",         limit: 50
    t.string   "resource",          limit: 20
    t.integer  "carbon"
    t.integer  "iron"
    t.integer  "nickel"
    t.integer  "phosphorus"
    t.integer  "sulphur"
    t.integer  "arsenic"
    t.integer  "chromium"
    t.integer  "germanium"
    t.integer  "manganese"
    t.integer  "selenium"
    t.integer  "vanadium"
    t.integer  "zinc"
    t.integer  "zirconium"
    t.integer  "cadmium"
    t.integer  "mercury"
    t.integer  "molybdenum"
    t.integer  "niobium"
    t.integer  "tin"
    t.integer  "tungsten"
    t.integer  "antimony"
    t.integer  "polonium"
    t.integer  "ruthenium"
    t.integer  "technetium"
    t.integer  "tellurium"
    t.integer  "yttrium"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.text     "notes"
    t.string   "image_url"
    t.string   "surveyed_by",                                               array: true
    t.integer  "system_id"
    t.integer  "world_id"
    t.datetime "surveyed_at"
    t.boolean  "error_flag",                   default: false, null: false
    t.text     "error_description"
    t.string   "error_updater"
    t.string   "ed_version"
    t.boolean  "numeric",                      default: false, null: false
  end

  add_index "surveys", ["basecamp_id", "commander", "resource", "updated_at"], name: "index_ssurveys_on_bc_com_res_upd", using: :btree
  add_index "surveys", ["basecamp_id"], name: "index_surveys_on_basecamp_id", using: :btree
  add_index "surveys", ["commander"], name: "index_surveys_on_commander", using: :btree
  add_index "surveys", ["resource"], name: "index_surveys_on_resource", using: :btree
  add_index "surveys", ["surveyed_by"], name: "index_surveys_on_surveyed_by", using: :gin
  add_index "surveys", ["system_id"], name: "index_surveys_on_system_id", using: :btree
  add_index "surveys", ["updated_at"], name: "index_surveys_on_updated_at", using: :btree
  add_index "surveys", ["world_id", "error_flag"], name: "index_surveys_on_world_id_and_error_flag", using: :btree
  add_index "surveys", ["world_id"], name: "index_surveys_on_world_id", using: :btree

  create_table "systems", force: :cascade do |t|
    t.string   "system"
    t.string   "updater"
    t.float    "x"
    t.float    "y"
    t.float    "z"
    t.string   "poi_name"
    t.string   "notes"
    t.string   "image_url"
    t.string   "tags",                    array: true
    t.string   "updaters",                array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "systems", ["system", "updated_at"], name: "index_systems_on_nam_upd", using: :btree
  add_index "systems", ["system", "x", "y", "z"], name: "index_systems_on_nam_xyz", using: :btree
  add_index "systems", ["system"], name: "index_systems_on_system", using: :btree
  add_index "systems", ["updater"], name: "index_systems_on_updater", using: :btree
  add_index "systems", ["updaters"], name: "index_systems_on_updaters", using: :gin

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
    t.string   "role",                   default: "user"
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
    t.integer  "world_id"
    t.string   "updater"
    t.boolean  "carbon",     default: false, null: false
    t.boolean  "iron",       default: false, null: false
    t.boolean  "nickel",     default: false, null: false
    t.boolean  "phosphorus", default: false, null: false
    t.boolean  "sulphur",    default: false, null: false
    t.boolean  "arsenic",    default: false, null: false
    t.boolean  "chromium",   default: false, null: false
    t.boolean  "germanium",  default: false, null: false
    t.boolean  "manganese",  default: false, null: false
    t.boolean  "selenium",   default: false, null: false
    t.boolean  "vanadium",   default: false, null: false
    t.boolean  "zinc",       default: false, null: false
    t.boolean  "zirconium",  default: false, null: false
    t.boolean  "cadmium",    default: false, null: false
    t.boolean  "mercury",    default: false, null: false
    t.boolean  "molybdenum", default: false, null: false
    t.boolean  "niobium",    default: false, null: false
    t.boolean  "tin",        default: false, null: false
    t.boolean  "tungsten",   default: false, null: false
    t.boolean  "antimony",   default: false, null: false
    t.boolean  "polonium",   default: false, null: false
    t.boolean  "ruthenium",  default: false, null: false
    t.boolean  "technetium", default: false, null: false
    t.boolean  "tellurium",  default: false, null: false
    t.boolean  "yttrium",    default: false, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "updaters",                                array: true
    t.integer  "system_id"
  end

  add_index "world_surveys", ["system_id"], name: "index_world_surveys_on_system_id", using: :btree
  add_index "world_surveys", ["updated_at"], name: "index_world_surveys_on_updated_at", using: :btree
  add_index "world_surveys", ["updater"], name: "index_world_surveys_on_updater", using: :btree
  add_index "world_surveys", ["updaters"], name: "index_world_surveys_on_updaters", using: :gin
  add_index "world_surveys", ["world_id", "updater", "updated_at"], name: "index_world_surveys_on_wor_upr_upd", using: :btree
  add_index "world_surveys", ["world_id"], name: "index_world_surveys_on_world", using: :btree

  create_table "worlds", force: :cascade do |t|
    t.string   "system_name",        limit: 50
    t.string   "updater",            limit: 50
    t.string   "world",              limit: 50
    t.string   "world_type"
    t.float    "mass"
    t.float    "radius"
    t.float    "gravity"
    t.integer  "surface_temp"
    t.float    "surface_pressure"
    t.float    "orbit_period"
    t.float    "rotation_period"
    t.float    "semi_major_axis"
    t.integer  "terrain_difficulty"
    t.string   "vulcanism_type",     limit: 30
    t.float    "rock_pct"
    t.float    "metal_pct"
    t.float    "ice_pct"
    t.string   "reserve"
    t.float    "arrival_point"
    t.text     "notes"
    t.string   "terraformable",      limit: 30
    t.string   "atmosphere_type",    limit: 30
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "image_url"
    t.string   "updaters",                                   array: true
    t.integer  "system_id"
  end

  add_index "worlds", ["system_id"], name: "index_worlds_on_system_id", using: :btree
  add_index "worlds", ["system_name", "world", "updated_at"], name: "index_worlds_on_sys_sta_upd", using: :btree
  add_index "worlds", ["system_name"], name: "index_worlds_on_system_name", using: :btree
  add_index "worlds", ["updated_at"], name: "index_worlds_on_updated_at", using: :btree
  add_index "worlds", ["updater"], name: "index_worlds_on_updater", using: :btree
  add_index "worlds", ["updaters"], name: "index_worlds_on_updaters", using: :gin
  add_index "worlds", ["world"], name: "index_worlds_on_star", using: :btree

end
