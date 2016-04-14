class RemoveSurveyedByFromWorldSurvey < ActiveRecord::Migration
  def up
    remove_column :world_surveys, :surveyed_by
  end
  
  def down
    add_column :world_surveys, :surveyed_by, :string, array: true
  end
end
