class RenameSystemFieldToSystemName < ActiveRecord::Migration
  def change
    rename_column :worlds, :system, :system_name
    rename_column :stars, :system, :system_name
  end
end
