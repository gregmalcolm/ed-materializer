class RenameNoteToNotes < ActiveRecord::Migration
  def change
    rename_column :stars, :note, :notes
  end
end
