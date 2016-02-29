class WorldSurveyToWorldSurveyV1 < ActiveRecord::Migration
  def change
    rename_index :world_surveys, "index_world_surveys_on_commander", "index_world_surveys_v1_on_commander"
    rename_index :world_surveys, "index_world_surveys_on_sys_com_wor_upd", "index_world_surveys_v1_on_sys_com_wor_upd" 
    rename_index :world_surveys, "index_world_surveys_on_system", "index_world_surveys_v1_on_system"
    rename_index :world_surveys, "index_world_surveys_on_updated_at", "index_world_surveys_v1_on_updated_at"
    rename_index :world_surveys, "index_world_surveys_on_world", "index_world_surveys_v1_on_world"

    rename_table :world_surveys, :world_surveys_v1
  end
end
