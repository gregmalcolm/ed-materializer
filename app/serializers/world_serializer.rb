class WorldSerializer < ActiveModel::Serializer
  attribute  :id
  attribute  :system_name, key: :system
  attributes :updater,
             :world,
             :world_type,
             :mass,
             :radius,
             :gravity,
             :surface_temp,
             :surface_pressure,
             :orbit_period,
             :rotation_period,
             :semi_major_axis,
             :terrain_difficulty,
             :vulcanism_type,
             :rock_pct,
             :metal_pct,
             :ice_pct,
             :reserve,
             :arrival_point,
             :terraformable,
             :atmosphere_type,
             :notes,
             :image_url,
             :creator,
             :updated_at,
             :created_at
end
