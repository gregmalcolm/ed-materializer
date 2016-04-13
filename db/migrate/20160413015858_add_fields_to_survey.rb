class AddFieldsToSurvey < ActiveRecord::Migration
  def change
    add_column :surveys, :world_id, :integer
    add_column :surveys, :surveyed_at, :datetime
    add_column :surveys, :error_flag, :boolean
    add_column :surveys, :error_description, :text

    add_index :surveys, :world_id
  end
end
