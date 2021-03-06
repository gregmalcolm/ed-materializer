class WorldSurveySerializer < ActiveModel::Serializer
  attributes :id,
             :world_id,
             :updater,
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
             :yttrium,
             :updaters,
             :creator,
             :updated_at,
             :created_at
  belongs_to :world
  belongs_to :system
end
