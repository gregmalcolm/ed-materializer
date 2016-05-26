class AddEdVersionAndNumericSurveys < ActiveRecord::Migration
  def change
    add_column :surveys, :ed_version, :string
    add_column :surveys, :numeric, :boolean, default: false, null: false
  end
end
