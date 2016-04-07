class AddSurveyors < ActiveRecord::Migration
  def change
    add_column :world_surveys, :surveyed_by, :string, array: true
    add_column :site_surveys, :surveyed_by, :string, array: true

    add_index :world_surveys, :surveyed_by, using: :gin
    add_index :site_surveys, :surveyed_by, using: :gin
  end
end
