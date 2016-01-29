class SurfaceTempShouldBeAnInt < ActiveRecord::Migration
  def up
    remove_column :star_surveys, :surface_temp
    add_column :star_surveys, :surface_temp, :int
  end

  def down
    remove_column :star_surveys, :surface_temp
    add_column :star_surveys, :surface_temp, :float
  end
end
