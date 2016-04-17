class NoMoreTriStateBooleans < ActiveRecord::Migration
  def up
    Survey.where(error_flag: nil).update_all(error_flag: false)
    change_column :surveys, :error_flag, :boolean, null: false, default: false

    %w[carbon iron nickel phosphorus sulphur arsenic chromium germanium 
    manganese selenium vanadium zinc zirconium cadmium mercury 
    molybdenum niobium tin tungsten antimony polonium ruthenium 
    technetium tellurium yttrium].each do |m|
      WorldSurvey.where(m => nil).update_all(m => false)
      change_column :world_surveys, m, :boolean, null: false, default: false
    end
  end

  def down
    change_column :surveys, :error_flag, :boolean
    %w[carbon iron nickel phosphorus sulphur arsenic chromium germanium 
    manganese selenium vanadium zinc zirconium cadmium mercury 
    molybdenum niobium tin tungsten antimony polonium ruthenium 
    technetium tellurium yttrium].each do |m|
      change_column :world_surveys, m, :boolean
    end
  end
end
