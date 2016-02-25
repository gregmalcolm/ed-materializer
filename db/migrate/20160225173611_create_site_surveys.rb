class CreateSiteSurveys < ActiveRecord::Migration
  def change
    create_table :site_surveys do |t|
      t.integer :basecamp_id
      t.string :commander, limit: 50
      t.string :resource, limit: 20
      t.integer :carbon
      t.integer :iron
      t.integer :nickel
      t.integer :phosphorus
      t.integer :sulphur
      t.integer :arsenic
      t.integer :chromium
      t.integer :germanium
      t.integer :manganese
      t.integer :selenium
      t.integer :vanadium
      t.integer :zinc
      t.integer :zirconium
      t.integer :cadmium
      t.integer :mercury
      t.integer :molybdenum
      t.integer :niobium
      t.integer :tin
      t.integer :tungsten
      t.integer :antimony
      t.integer :polonium
      t.integer :ruthenium
      t.integer :technetium
      t.integer :tellurium
      t.integer :yttrium
      t.timestamps null:false
    end
    add_index :site_surveys, :basecamp_id
    add_index :site_surveys, :commander
    add_index :site_surveys, :resource
    add_index :site_surveys, :updated_at
    add_index :site_surveys, [:basecamp_id, :commander, :resource, :updated_at], name: "index_ssurveys_on_bc_com_res_upd"
  end
end
