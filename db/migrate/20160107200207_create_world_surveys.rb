# Generated with:
# rails g scaffold world_surveys system:string commander:string world:string world_type:string terraformable:boolean gravity:float terrain_difficulty:integer notes:text carbon:boolean iron:boolean nickel:boolean phosphorus:boolean sulphur:boolean arsenic:boolean chromium:boolean germanium:boolean manganese:boolean selenium:boolean vanadium:boolean zinc:boolean zirconium:boolean cadmium:boolean mercury:boolean molybdenum:boolean niobium:boolean tin:boolean tungsten:boolean antimony:boolean polonium:boolean ruthenium:boolean technetium:boolean tellurium:boolean yttrium:boolean

class CreateWorldSurveys < ActiveRecord::Migration
  def change
    create_table :world_surveys do |t|
      t.string :system
      t.string :commander
      t.string :world
      t.string :world_type
      t.boolean :terraformable
      t.float :gravity
      t.integer :terrain_difficulty
      t.text :notes
      t.boolean :carbon
      t.boolean :iron
      t.boolean :nickel
      t.boolean :phosphorus
      t.boolean :sulphur
      t.boolean :arsenic
      t.boolean :chromium
      t.boolean :germanium
      t.boolean :manganese
      t.boolean :selenium
      t.boolean :vanadium
      t.boolean :zinc
      t.boolean :zirconium
      t.boolean :cadmium
      t.boolean :mercury
      t.boolean :molybdenum
      t.boolean :niobium
      t.boolean :tin
      t.boolean :tungsten
      t.boolean :antimony
      t.boolean :polonium
      t.boolean :ruthenium
      t.boolean :technetium
      t.boolean :tellurium
      t.boolean :yttrium

      t.timestamps null: false
    end
  end
end
