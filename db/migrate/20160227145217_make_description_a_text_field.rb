class MakeDescriptionATextField < ActiveRecord::Migration
  def change
    rename_column :basecamps, :descripton, :description
    change_column :basecamps, :description, :text
  end
end
