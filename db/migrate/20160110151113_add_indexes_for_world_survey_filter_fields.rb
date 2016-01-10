class AddIndexesForWorldSurveyFilterFields < ActiveRecord::Migration
  def change
    add_index :world_surveys, :system
    add_index :world_surveys, :commander
    add_index :world_surveys, :world
    add_index :world_surveys, :updated_at
    add_index :world_surveys, [:system, :commander, :world, :updated_at], name: "index_world_surveys_on_sys_com_wor_upd"
  end
end
