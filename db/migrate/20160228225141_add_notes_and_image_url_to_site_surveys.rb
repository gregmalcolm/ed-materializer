class AddNotesAndImageUrlToSiteSurveys < ActiveRecord::Migration
  def change
    add_column :site_surveys, :notes, :text
    add_column :site_surveys, :image_url, :string
  end
end
