class RemoveIsPrimaryFromStarSurveys < ActiveRecord::Migration
  def up
    remove_index :star_surveys, name: "index_star_surveys_on_sys_com_upd"
    remove_column :star_surveys, :is_primary_star
    add_index :star_surveys, [:system, :commander, :star, :updated_at], name: "index_star_surveys_on_sys_com_upd"
  end

  def down
    remove_index :star_surveys, name: "index_star_surveys_on_sys_com_upd"
    add_column :star_surveys, :is_primary_star, :boolean
    add_index :star_surveys, :is_primary_star
    add_index :star_surveys, [:system, :commander, :star, :is_primary_star, :updated_at], name: "index_star_surveys_on_sys_com_upd"
  end
end
