class CreateStars < ActiveRecord::Migration
  def change
    create_table "stars" do |t|
      t.string   "system",        limit: 50
      t.string   "updater"   ,    limit: 50
      t.string   "star",          limit: 50
      t.string   "star_type"
      t.string   "subclass"
      t.float    "solar_mass"
      t.float    "solar_radius"
      t.float    "star_age"
      t.float    "orbit_period"
      t.float    "arrival_point"
      t.string   "luminosity"
      t.text     "note"
      t.integer  "surface_temp"
      t.timestamps null: false
    end

    add_index "stars", ["system"], name: "index_stars_on_system"
    add_index "stars", ["star"], name: "index_stars_on_star"
    add_index "stars", ["updated_at"], name: "index_stars_on_updated_at"
    add_index "stars", ["system", "star", "updated_at"], name: "index_stars_on_sys_sta_upd"
    add_index "stars", ["updater"], name: "index_stars_on_updater"
  end
end
