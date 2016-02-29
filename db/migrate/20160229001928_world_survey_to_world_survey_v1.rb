class WorldSurveyToWorldSurveyV1 < ActiveRecord::Migration
  def up
    rename_index :world_surveys, "index_world_surveys_on_commander",       "index_world_survey_v1s_on_commander"
    rename_index :world_surveys, "index_world_surveys_on_sys_com_wor_upd", "index_world_survey_v1s_on_sys_com_wor_upd" 
    rename_index :world_surveys, "index_world_surveys_on_system",          "index_world_survey_v1s_on_system"
    rename_index :world_surveys, "index_world_surveys_on_updated_at",      "index_world_survey_v1s_on_updated_at"
    rename_index :world_surveys, "index_world_surveys_on_world",           "index_world_survey_v1s_on_world"

    rename_table :world_surveys, :world_survey_v1s
  end
  
  def down
    rename_index :world_survey_v1s, "index_world_survey_v1s_on_commander",       "index_world_surveys_on_commander"
    rename_index :world_survey_v1s, "index_world_survey_v1s_on_sys_com_wor_upd", "index_world_surveys_on_sys_com_wor_upd" 
    rename_index :world_survey_v1s, "index_world_survey_v1s_on_system",          "index_world_surveys_on_system"
    rename_index :world_survey_v1s, "index_world_survey_v1s_on_updated_at",      "index_world_surveys_on_updated_at"
    rename_index :world_survey_v1s, "index_world_survey_v1s_on_world",           "index_world_surveys_on_world"

    rename_table :world_survey_v1s, :world_surveys
  end
end
