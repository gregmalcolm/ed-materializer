class AddSystemIdsToSearchableModels < ActiveRecord::Migration
  def change
    add_column :stars, :system_id, :integer
    add_column :worlds, :system_id, :integer
    add_column :world_surveys, :system_id, :integer
    add_column :site_surveys, :system_id, :integer

    add_index :stars, :system_id
    add_index :worlds, :system_id
    add_index :world_surveys, :system_id
    add_index :site_surveys, :system_id
  end
end
