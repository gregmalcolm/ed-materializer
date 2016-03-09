class AddUpdatersToUpdatableTables < ActiveRecord::Migration
  def change
    add_column :stars, :updaters, :string, array: true
    add_column :worlds, :updaters, :string, array: true
    add_column :world_surveys, :updaters, :string, array: true
    add_column :basecamps, :updaters, :string, array: true

    add_index :stars, :updaters, using: 'gin'
    add_index :worlds, :updaters, using: 'gin'
    add_index :world_surveys, :updaters, using: 'gin'
    add_index :basecamps, :updaters, using: 'gin'
  end
end
