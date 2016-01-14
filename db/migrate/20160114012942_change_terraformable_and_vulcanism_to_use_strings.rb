class ChangeTerraformableAndVulcanismToUseStrings < ActiveRecord::Migration
  def up
    remove_column :world_surveys, :terraformable
    add_column :world_surveys, :terraformable, :string, limit: 30

    remove_column :world_surveys, :vulcanism_type
    add_column :world_surveys, :vulcanism_type, :string, limit: 30
  end

  def down
    remove_column :world_surveys, :terraformable
    add_column :world_surveys, :terraformable, :boolean

    remove_column :world_surveys, :vulcanism_type
    add_column :world_surveys, :vulcanism_type, :integer
  end
end
