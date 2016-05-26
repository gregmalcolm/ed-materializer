class AddSurveySpecificsToBasecamps < ActiveRecord::Migration
  def change
    add_column :basecamps, :ed_version, :string
    add_column :basecamps, :numeric, :boolean, default: false, null: false
  end
end
