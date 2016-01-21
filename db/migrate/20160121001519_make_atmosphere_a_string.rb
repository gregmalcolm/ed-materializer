class MakeAtmosphereAString < ActiveRecord::Migration
  def up
    remove_column :world_surveys, :atmosphere_type
    add_column :world_surveys, :atmosphere_type, :string, limit: 30
  end

  def down
    remove_column :world_surveys, :atmosphere_type
    add_column :world_surveys, :atmosphere_type, :integer
  end
end
