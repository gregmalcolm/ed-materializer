class AddErrorUpdaterToSurveys < ActiveRecord::Migration
  def change
    add_column :surveys, :error_updater, :string
    add_index :surveys, %w[world_id error_flag]
  end
end
