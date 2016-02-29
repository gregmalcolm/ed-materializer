class CreateWorldSurveysV2 < ActiveRecord::Migration
  def change
    create_table :world_surveys do |t|
      t.integer :world_id
      t.string  :updater
      t.boolean :carbon
      t.boolean :iron
      t.boolean :nickel
      t.boolean :phosphorus
      t.boolean :sulphur
      t.boolean :arsenic
      t.boolean :chromium
      t.boolean :germanium
      t.boolean :manganese
      t.boolean :selenium
      t.boolean :vanadium
      t.boolean :zinc
      t.boolean :zirconium
      t.boolean :cadmium
      t.boolean :mercury
      t.boolean :molybdenum
      t.boolean :niobium
      t.boolean :tin
      t.boolean :tungsten
      t.boolean :antimony
      t.boolean :polonium
      t.boolean :ruthenium
      t.boolean :technetium
      t.boolean :tellurium
      t.boolean :yttrium
      t.timestamps null: false
    end

    add_index :world_surveys, ["updater"], name: "index_world_surveys_on_updater"
    add_index :world_surveys, ["world_id"], name: "index_world_surveys_on_world"
    add_index :world_surveys, ["updated_at"], name: "index_world_surveys_on_updated_at"
    add_index :world_surveys, ["world_id", "updater", "updated_at"], name: "index_world_surveys_on_wor_upr_upd"
  end
end
