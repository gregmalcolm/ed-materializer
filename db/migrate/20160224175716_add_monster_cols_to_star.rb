class AddMonsterColsToStar < ActiveRecord::Migration
  def change
    rename_column :stars, :star_type, :spectral_class
    rename_column :stars, :subclass, :spectral_subclass
  end
end
