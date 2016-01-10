class WorldSurveySerializer < ActiveModel::ArraySerializer
  attributes :system,
             :commander,
             :world,
             :world_type,
             :terraformable,
             :gravity,
             :terrain_difficulty,
             :notes,
             :carbon,
             :iron,
             :nickel,
             :phosphorus,
             :sulphur,
             :arsenic,
             :chromium,
             :germanium,
             :manganese,
             :selenium,
             :vanadium,
             :zinc,
             :zirconium,
             :cadmium,
             :mercury,
             :molybdenum,
             :niobium,
             :tin,
             :tungsten,
             :antimony,
             :polonium,
             :ruthenium,
             :technetium,
             :tellurium,
             :yttrium
end