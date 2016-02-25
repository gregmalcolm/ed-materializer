class CreateBasecamp < ActiveRecord::Migration
  def change
    create_table :basecamps do |t|
      t.integer :world_id
      t.string :updater, limit: 50
      t.string :name, limit: 50
      t.string :descripton
      t.string :landing_zone_terrain, limit: 30
      t.integer :terrain_hue_1
      t.integer :terrain_hue_2
      t.integer :terrain_hue_3
      t.float :landing_zone_lat
      t.float :landing_zone_lon
      t.text :notes
      t.string :image_url
      t.timestamps null: false
    end

    add_index :basecamps, :world_id
    add_index :basecamps, :updater
    add_index :basecamps, :updated_at
    add_index :basecamps, [:world_id, :updater, :updated_at], name: "index_basecamps_on_wor_updr_upd"
  end
end
