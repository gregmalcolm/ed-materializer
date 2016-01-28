class AddColumnsToWorldSurveys < ActiveRecord::Migration
  def change
    add_column :world_surveys, :reserve, :string
    add_column :world_surveys, :mass, :float
    add_column :world_surveys, :surface_temp, :integer
    add_column :world_surveys, :surface_pressure, :float
    add_column :world_surveys, :orbit_period, :float
    add_column :world_surveys, :rotation_period, :float
    add_column :world_surveys, :semi_major_axis, :float
    add_column :world_surveys, :rock_pct, :float
    add_column :world_surveys, :metal_pct, :float
    add_column :world_surveys, :ice_pct, :float
  end
end
