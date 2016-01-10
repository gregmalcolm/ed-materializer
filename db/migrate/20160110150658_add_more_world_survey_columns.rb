class AddMoreWorldSurveyColumns < ActiveRecord::Migration
  def change
    add_column :world_surveys, :arrival_point, :float
    add_column :world_surveys, :atmosphere_type, :integer
    add_column :world_surveys, :vulcanism_type, :integer
    add_column :world_surveys, :radius, :float
  end
end
