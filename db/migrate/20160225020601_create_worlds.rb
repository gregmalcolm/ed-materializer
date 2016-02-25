class CreateWorlds < ActiveRecord::Migration
  def change
    create_table :worlds do |t|
      t.string   :system,             limit: 50
      t.string   :updater,            limit: 50
      t.string   :world,              limit: 50
      t.string   :world_type
      t.float    :mass
      t.float    :radius
      t.float    :gravity
      t.integer  :surface_temp
      t.float    :surface_pressure  #Might not need this, looks like calculated data
      t.float    :orbit_period
      t.float    :rotation_period
      t.float    :semi_major_axis
      t.integer  :terrain_difficulty
      t.string   :vulcanism_type,     limit: 30
      t.float    :rock_pct
      t.float    :metal_pct
      t.float    :ice_pct
      t.string   :reserve
      t.float    :arrival_point
      t.text     :notes
      t.string   :terraformable,      limit: 30
      t.string   :atmosphere_type,    limit: 30
      t.timestamps null: false
    end
    
    add_index :worlds, ["system"], name: "index_worlds_on_system"
    add_index :worlds, ["world"], name: "index_worlds_on_star"
    add_index :worlds, ["updated_at"], name: "index_worlds_on_updated_at"
    add_index :worlds, ["system", "world", "updated_at"], name: "index_worlds_on_sys_sta_upd"
    add_index :worlds, ["updater"], name: "index_worlds_on_updater"
  end
end
