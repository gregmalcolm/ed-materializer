class AddSystems < ActiveRecord::Migration
  def change
    create_table "systems" do |t|
      t.string :system
      t.string :updater
      t.float  :x
      t.float  :y
      t.float  :z
      t.string :poi_name
      t.string :notes
      t.string :image_url
      t.string :tags, array: true
      t.string :updaters, array: true
      t.timestamps null: false
    end

    add_index :systems, %w[system updated_at], name: "index_systems_on_nam_upd"
    add_index :systems, %w[system x y z], name: "index_systems_on_nam_xyz"
    add_index :systems, :system
    add_index :systems, :updater
    add_index :systems, :updaters, using: :gin
  end
end
