class RemoveV1Tables < ActiveRecord::Migration
  def up
    drop_table :star_surveys
    drop_table :world_survey_v1s
  end

  def down
    create_table "star_surveys", force: :cascade do |t|
      t.string   "system"
      t.string   "commander"
      t.string   "star",          limit: 30
      t.string   "star_type"
      t.string   "subclass"
      t.float    "solar_mass"
      t.float    "solar_radius"
      t.float    "star_age"
      t.float    "orbit_period"
      t.float    "arrival_point"
      t.string   "luminosity"
      t.text     "note"
      t.datetime "created_at",               null: false
      t.datetime "updated_at",               null: false
      t.integer  "surface_temp"
    end

    add_index "star_surveys", ["commander"], name: "index_star_surveys_on_commander", using: :btree
    add_index "star_surveys", ["star"], name: "index_star_surveys_on_star", using: :btree
    add_index "star_surveys", ["system", "commander", "star", "updated_at"], name: "index_star_surveys_on_sys_com_upd", using: :btree
    add_index "star_surveys", ["system"], name: "index_star_surveys_on_system", using: :btree
    add_index "star_surveys", ["updated_at"], name: "index_star_surveys_on_updated_at", using: :btree
  
    create_table "world_survey_v1s", force: :cascade do |t|
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

    add_index "world_survey_v1s", ["commander"], name: "index_world_survey_v1s_on_commander", using: :btree
    add_index "world_survey_v1s", ["system", "commander", "world", "updated_at"], name: "index_world_survey_v1s_on_sys_com_wor_upd", using: :btree
    add_index "world_survey_v1s", ["system"], name: "index_world_survey_v1s_on_system", using: :btree
    add_index "world_survey_v1s", ["updated_at"], name: "index_world_survey_v1s_on_updated_at", using: :btree
    add_index "world_survey_v1s", ["world"], name: "index_world_survey_v1s_on_world", using: :btree
  end
end
