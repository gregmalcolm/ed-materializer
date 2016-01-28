class CreateStarSurveys < ActiveRecord::Migration
  def change
    create_table :star_surveys do |t|
      t.string   "system"
      t.string   "commander"
      t.string   "star", limit: 30
      t.boolean  "is_primary_star"
      t.string   "star_type"
      t.string   "subclass"
      t.float    "solar_mass"
      t.float    "solar_radius"
      t.float    "surface_temp"
      t.float    "star_age"
      t.float    "orbit_period"
      t.float    "arrival_point"
      t.string   "luminosity"
      t.text     "note"

      t.timestamps null: false
    end

    add_index :star_surveys, :system
    add_index :star_surveys, :commander
    add_index :star_surveys, :star
    add_index :star_surveys, :is_primary_star
    add_index :star_surveys, :updated_at
    add_index :star_surveys, [:system, :commander, :star, :is_primary_star, :updated_at], name: "index_star_surveys_on_sys_com_upd"
  end
end
