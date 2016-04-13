class RenameSiteSurveyToJustSurvey < ActiveRecord::Migration
  def change
    rename_table :site_surveys, :surveys
  end
end
